package main

import (
	"net"
	"os"
	"log"
	"math/rand"
	"time"
	"encoding/json"
	"fmt"
	"bufio"
	"strings"
	"strconv"
)

func main(){
	host := os.Args[1]
	port := os.Args[2]
	server := host + ":" + port 
	serveraddr,err := net.ResolveTCPAddr("tcp",server)
	if err != nil {
		log.Fatal("can not resovle remote address",err)
	}
	
	//连接服务器
	conn,err := net.DialTCP("tcp",nil,serveraddr)
    if err != nil{
		log.Fatal("can not connect to server\n",err)
	}
	
	sendRandomMessage(conn)
    //readFromStdin(conn)
	
	//关闭连接
	if err := conn.Close(); err != nil{
		log.Fatal("can not close socket", err)
	}
}

//通信消息格式
type Message struct{
	Command string   //命令
	Key     string   //键
	Value   int       //值
	Status   bool     //服务器回复命令执行结果
}
                                                
var charset [26]byte = [26]byte {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
                        'p','q','r','s','t','u','v','w','x','y','z'}
  
//消息处理
func sendAndRecvMessage(enc *json.Encoder, dec *json.Decoder, cmd string, key string, value int){
	var send Message //用于发送消息
	var receive Message //用于接受消息
	
	send.Command = cmd
	send.Key = key 
	send.Value = value

    //发送消息
	if err := enc.Encode(&send); err != nil{
		log.Println("Can not send message to server ", err)
		return 
	}

	time.Sleep(1*time.Second)
		
	//读取消息
	if err := dec.Decode(&receive);err != nil{
		log.Println("Can not receive message from server ", err)
		return 
	}
	
	switch receive.Command {
	case "set":
		if receive.Status {
		    fmt.Printf("[ %s %s = %d ] =>Ok\n",receive.Command,receive.Key,receive.Value)
		} else{
			fmt.Printf("[ %s %s = %d ] =>Failed\n",receive.Command,receive.Key,receive.Value)
		}
	case "get":
        if receive.Status {
			fmt.Printf("%d \n", receive.Value)
		}else{
			fmt.Printf("The value of key %s is not exists\n",receive.Key)
		}
	default:
		fmt.Printf("Default\n")
	}

}

//随机key:value对生成器
func randomKVGen()(string,int){
	var key string 
	var value int 
	rand.Seed(time.Now().UnixNano())
	
	//生成key,最多包含10个字符
	kn := rand.Intn(10)
	if kn == 0 {
       kn += 1 
	}
	for ; kn >0; kn--{
		i := rand.Intn(26)
		key = key + string(charset[i])
	}
	
	//生成value
	value = rand.Intn(100000)
	return key,value 
}

//与服务器交互,发送随机消息，用于测试
func sendRandomMessage(conn *net.TCPConn){
    //生成json输入输出流
	enc := json.NewEncoder(conn)
	dec := json.NewDecoder(conn)
	
	for n := 100; n >0; n--{
	    cmd := "set"
		k,v := randomKVGen()
		sendAndRecvMessage(enc,dec,cmd,k,v)
	}
}

//从标准输入读命令
func readFromStdin(conn *net.TCPConn){
	//生成json输入输出流
	enc := json.NewEncoder(conn)
	dec := json.NewDecoder(conn)
	var cmd, key string 
	var value int 

    scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		s := scanner.Text()
		ss := strings.Fields(s)
		if len(ss) == 2{
			value = 0
		}else{
			v, err := strconv.Atoi(ss[2])
            if err != nil{
				log.Printf("parsing value failed from stdio\n")
			}
			value = v 
		}
		cmd = ss[0]
		key = ss[1]
		
		sendAndRecvMessage(enc,dec,cmd,key,value)
	}
}

