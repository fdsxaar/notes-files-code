package main 

import(
	"os"
	"net"
	"log"
	"encoding/json"
	"sync"
	"fmt"
	"strconv"
)

var (
	hashmap = make(map[string]int)  //存储客户端发来的键值对数据，注：会出现<键冲突>问题
	mu sync.Mutex    //互斥锁，保护全局变量hashmap
	msgch = make(chan MessageCh, 1024) //用于接受键值对的通道
	psync bool = false 
	psyncbuf []psyncelement //临时缓冲，存储在完全同步时，主服务器接受到的修改的键值对
	backlogbuf [10000]backlogElement  //复制积压缓冲区，存储主复制将要发往从复制的数据
	index int = 0 
)

func main(){
	host := os.Args[1]
	port := os.Args[2]
	addr := host + ":" + port 
	listenaddr,err := net.ResolveTCPAddr("tcp",addr)
	if err != nil {
		log.Fatal("can not resovle listen addr",err)
	}
	
	//监听
	l,err := net.ListenTCP("tcp",listenaddr); 
	if err != nil{
		log.Fatal("can not listen", err)
	}
	
	//执行AOF持久化
	go aofSave()

	//等待连接到来
    for{
		conn,err := l.AcceptTCP()
		if err != nil{
			log.Fatal("AcceptTCP failed", err)
		}

		//处理连接
		go handleConn(conn)
	}

}

//通信消息格式
type Message struct{
	Command string   //命令
	Key     string   //键
	Value   int       //值
	Status   bool     //服务器回复命令执行结果
}

//用于在通道中传输键值对
type MessageCh struct{
	Command string   //命令
	Key      string  //键
	Value    int     //值
}

//复制积压缓冲区中的元素
type backlogElement struct{
	offset   int   //偏移量
	key     string    //键
	value   int       //值
}

//psyncbuf中的元素
type psyncelement struct{
	key string   //键
	value int    //值
}

//存储键值对
func setKeyValue(key string, value int){
	mu.Lock()
	defer 	mu.Unlock()

	hashmap[key] = value 
	//将数据存入复制积压缓冲区backlogbuf
    if index > 9999{
		index = 0 
		bk := backlogElement{
			offset:index,
			key:key,
			value:value,
		}
		backlogbuf[index] = bk 
		index++ 
	}else{
        bk := backlogElement{
			offset:index,
			key:key,
			value:value,
		}
		backlogbuf[index] = bk 
		index++ 
	}
	//将数据存入临时缓冲区psyncbuf,只有在进行psync时才将数据加入psyncbuf 
	if psync == true{
	    pele := psyncelement{
		    key:key,
		    value:value,
	    }
	   psyncbuf = append(psyncbuf,pele)
    }
}

//读取值
func getValue(key string)(int, bool){
	mu.Lock()
	defer mu.Unlock()
	v,ok := hashmap[key]
	if ok{
		return v,true
	}else{
		return 0,false 
	}	
}

//处理客户端连接
func handleConn(conn *net.TCPConn){
	clientaddr := conn.RemoteAddr().String()
	var receive Message //用于接受消息

	dec := json.NewDecoder(conn)
	enc := json.NewEncoder(conn)

	for{
        if err := dec.Decode(&receive); err != nil{
			//注：应当调用net.close(conn)
			log.Fatal("can not decode message from  ", clientaddr)
		}
		cmd := receive.Command
		k := receive.Key
		v := receive.Value
		
		mch := MessageCh{
			Command: cmd,
			Key: k,
            Value : v,
		}

		switch cmd {
		case "set":
			//执行命令，存储键值对
			setKeyValue(k,v)

			//向管道发送命令，用于aof持久化
            msgch <- mch 
			receive.Status = true 
		    if err := enc.Encode(&receive); err != nil{
			    log.Fatal("can not send message to ", clientaddr)
			}
			
		case "get":
			v,b := getValue(k)
			receive.Status = b
			receive.Value = v 
			if err := enc.Encode(&receive); err != nil{
			    log.Fatal("can not send message to ", clientaddr) 
			}
		
		case "replof":    //命令replof host,开始复制主服务器的数据，与主服务器同步
		    
			host := k
			port := v 
			server := host + ":" + strconv.Itoa(port)
	        serveraddr,err := net.ResolveTCPAddr("tcp",server)
	        if err != nil {
		        log.Fatal("can not resovle remote address",err)
	        }
	
	        //连接主服务器
	        conn,err := net.DialTCP("tcp",nil,serveraddr)
            if err != nil{
		        log.Fatal("can not connect to server\n",err)
			}

			go handleRepl(conn)      //处理与主服务器的同步过程
			return 
		
		case "psync":
			if k == "all" {    //完全同步
                go  handlePsync(conn) 
			}

		default:
			fmt.Printf("Default\n")
		}
	
	}
	
}

//用于持久化操作，将键值对写入AOF文件
func aofSave(){
	var aofBuf []MessageCh    //aof缓冲，存储从msgch传送过来的值
	var count uint64           //消息计数器，用于统计接受了多少条消息
	for msg := range msgch{
		aofBuf = append(aofBuf,msg) //将接受到的键值对消息结构体加入缓冲
		count++                 //递增计数器
		if count >= 10 {        //如果计数器大于10，则将缓存中的内容写到磁盘，Fix：还要考虑事件间隔
			//打开备份文件
            f, err := os.OpenFile("backup.aof", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
            if err != nil {
              log.Fatal("opening or creating backup.aof failed ",err)
            }
			
			//遍历写入aofBuf中的命令
			for _,m := range aofBuf{
				cmd := m.Command
				k := m.Key
				v := m.Value
				sv := strconv.Itoa(v)  //把值转换成string
				//组合成一条string格式消息
				sm := cmd  + " " + k + " " + sv + "\r\n"
				if _, err := f.WriteString(sm); err != nil {
					f.Close() 
					log.Fatal("writing command to backup.aof failed ",err)
				}
                
			}
			
			//立即同步到磁盘
		    if err := f.Sync(); err != nil {
				log.Fatal(err)
			}
			
			//关闭文件
            if err := f.Close(); err != nil {
               log.Fatal(err)
			}
			
			//重置计数器
		    count = 0 

		   //清除缓存中的内容
		   aofBuf = nil
		}
	}
}

//服务器重启时载入AOF文件
func loadAOF(){

}

//处理与主服务器的数据同步过程
func handleRepl(conn *net.TCPConn){
	//完全同步
	var send Message  //用于发送消息
	var receive Message //用于接受消息
	var response Message //用于告知主服务器，成功接受到数据 

    enc := json.NewEncoder(conn)
	dec := json.NewDecoder(conn)

	send.Command = "psync"
	send.Key = "all"
	send.Value = 1
    
	//发送消息
	if err := enc.Encode(&send); err != nil{
		log.Println("Can not send message to leader server ", err)
		if err := conn.Close(); err != nil{
			log.Println("can not close socket", err)
		}
		return  
	}
	
	for{
        //读取消息
	    if err := dec.Decode(&receive);err != nil{
			log.Println("Can not receive respond from follower ", err)
			if err := conn.Close(); err != nil{
				log.Println("can not close socket", err)
			}
			return    
		}
		
		k := receive.Key
		v := receive.Value 
		setKeyValue(k,v) 

		//回复消息，成功接受到数据
		
	    response.Status = true 
	    if err := enc.Encode(&response); err != nil{
		    log.Println("Can not send message to leader server ", err)
		    if err := conn.Close(); err != nil{
				log.Println("can not close socket", err)
		    }
		    return  
	    }
	}
}

//专门用于与从服务器之间的数据传输
func handlePsync(conn *net.TCPConn){
	enc := json.NewEncoder(conn)
	dec := json.NewDecoder(conn)

	var send Message  //用于发送消息
	var receive Message //用于接受消息
	psyncmap := make(map[string]int)  //临时map，赋值hashmap中的数据
	mu.Lock()                         //获取锁
	for k, v := range hashmap {      //复制hashmap
		psyncmap[k] = v
	} 
    //psync = true                     标志，表示开始psync 
	mu.Unlock()      //解锁
	
	//发送键值对数据
	for k, v := range psyncmap{
		//注：应添加一个ping功能，在构造psyncmap的过程中，连接可能断开
		send.Key = k
		send.Value = v 
	    if err := enc.Encode(&send); err != nil{
		   log.Println("Can not send message to server ", err)
		   if err := conn.Close(); err != nil{
			   log.Fatal("can not close socket", err)
		    }
		    return 
	    }
		
	    //读取消息
	    if err := dec.Decode(&receive);err != nil{
			log.Println("Can not receive respond from follower ", err)
			if err := conn.Close(); err != nil{
				log.Fatal("can not close socket", err)
			}
			return 
	    }
		
		if b := receive.Status; b == true{
			log.Printf("send %s =  %d Ok", k, v)
		}
	}

	//发送psyncbuf中的数据,清除psync中的数据 
	//广播消息 
}