package main

import (
	"github.com/etree"
	"strconv"
	"database/sql"
	"log"
)

//从data.xml中查找需要的数据，并写入数据库;
//执行dataMap[y][name]=value 赋值操作后，数据被插入dataMap,dataMap中嵌套的
//map的键值，即name的值，必须唯一
func parseAndSaveData(idts []indicator, dataMap map[int]map[string]string){

  doc := etree.NewDocument()
  if err := doc.ReadFromFile("data.xml"); err != nil {
    panic(err)
  }

  root := doc.SelectElement("Root")
  data := root.SelectElement("data")
  
  for _, idt := range idts{
	  
	  code := idt.code
	  name := idt.name 
	  key := "//record/field[@key='" + code + "']"   //所用的xpath
	  eles := data.FindElements(key)   //找到属性值key为code的fields
	  for _, ele := range eles{
		  p := ele.Parent()             //找到每个field的父element，即record
		  year :=p.FindElement("field[@name='Year']").Text()    //找到record下属性name='Year'的field的文本值
		  value := p.FindElement("field[@name='Value']").Text()   //找到record下属性name='Vaue'的field的文本值
		  y, err := strconv.Atoi(year)   //将年份转换成整数int
		  if err != nil{
			  panic(err)
		  }
		  if y == 2019 {
			  //
		  }else{	  
			 dataMap[y][name]=value
		  }
	  }
  }
}

//汇集每个表的数据，并插入该表，数据跨度2016年-2018年
func assemAndInsertData(db *sql.DB, dataMap map[int]map[string]string, table string, idts[]indicator){
	codename, err := db.Prepare("INSERT INTO datacodemap(code, name, namecn,note) VALUES( ?, ?, ?, ? )")
	
	if err!= nil{
		panic(err)
	}
	defer codename.Close() 

	//将code-name等信息插入数据库
	for _,v := range idts{
	   code := v.code
	   name := v.name 
	   namecn := v.namecn
	   note := v.note
       if _, err := codename.Exec(code, name, namecn, note); err != nil {
		panic(err)
	   }
	}
    
	switch table{
	//将数据插入表gdp
	case "gdp":{
		insert, err := db.Prepare("INSERT INTO gdp(year, gdp, growthrate, avgvalue, avggrowthrate) VALUES( ?, ?, ?, ?, ? )")
			if err!= nil{
				panic(err)
			}
		defer insert.Close() 

		for i:=1960; i<2019; i++{
			gdp := dataMap[i]["gdp"] 
			ngdp, ok := convtoint64(gdp) //转换成整数
			if ok == false {
				log.Fatal("convertion failed")
			}

			growthrate := dataMap[i]["growthrate"]

			avgvalue := dataMap[i]["avgvalue"]
			navgvalue, ok := convtofloat64(avgvalue) //转换成浮点数
			if ok == false {
				log.Fatal("convertion failed")
			}

			avggrowthrate := dataMap[i]["avggrowthrate"]

			if i == 1960{ //第一年是计算基础，没有增长率
                if _, err := insert.Exec(i,ngdp, nil, navgvalue, nil); err != nil {
					panic(err)
				}
			}else{
			   ngrowthrate,ok := convtofloat64(growthrate)
			   if ok == false {
				log.Fatal("convertion failed")
			   }
			   navggrowthrate, ok := convtofloat64(avggrowthrate)
			   if ok == false {
				log.Fatal("convertion failed")
			   }
			   if _, err := insert.Exec(i,ngdp, ngrowthrate, navgvalue, navggrowthrate); err != nil {
				panic(err)
			   }
			}
		}
	}
	//将数据插入表population
	case "population":{
        insert, err := db.Prepare("INSERT INTO population(year, total, femaleratio, 15to64, 15to64ratio) VALUES( ?, ?, ?, ?, ? )")
		if err!= nil{
			panic(err)
		}
		defer insert.Close() 

        for i:=1960; i<2019; i++{
			total := dataMap[i]["total"]
			femaleratio := dataMap[i]["femaleratio"]
			_15to64 := dataMap[i]["15to64"]
			_15to64ratio := dataMap[i]["15to64ratio"]
			ntotal,ok := convtoint64(total)
			if ok == false {
				log.Fatal("convertion failed")
			}
			mfemaleratio,ok := convtofloat64(femaleratio)
			if ok == false {
				log.Fatal("convertion failed")
			}
			n_15to64,ok := convtoint64(_15to64)
			if ok == false{
				log.Fatal("convertion failed")
			}
			n_15to64ratio,ok := convtofloat64(_15to64ratio)
			if ok == false{
				log.Fatal("convertion failed")
			}
			if _, err := insert.Exec(i,ntotal, mfemaleratio, n_15to64, n_15to64ratio); err != nil {
				panic(err)
			}
		}
	}
	//将数据插入表money
	case "money":{
	    insert, err := db.Prepare("INSERT INTO money(year,domestictotalsavings, realinterestrate) VALUES(?,?,? )")
	    if err!= nil{
		    panic(err)
	    }
		defer insert.Close() 
		
		for i:=1960; i<2019; i++{
			domestictotalsavings := dataMap[i]["domestictotalsavings"] 
			realinterestrate := dataMap[i]["realinterestrate"]
			ndomestictotalsavings, ok := convtoint64(domestictotalsavings)
			if ok == false {
				log.Fatal("convertion failed")
			}
			if realinterestrate == ""{
				if _,err := insert.Exec(i,ndomestictotalsavings,nil); err!=nil{
                   panic(err)
				}
			}else{
				nrealinterestrate, ok := convtofloat64(realinterestrate)
				if ok == false {
					log.Fatal("convertion failed")
				}
				if _,err := insert.Exec(i,ndomestictotalsavings,nrealinterestrate); err!=nil{
					panic(err)
				}
			}
		}
	}
	//将数据插入表income
	case "income":{
		insert, err := db.Prepare("INSERT INTO income(year,adjavgnetincomeratio) VALUES(?,? )")
	    if err!= nil{
		    panic(err)
	    }
		defer insert.Close()	
		for i:=1960; i<2019;i++{
			adjavgnetincomeratio := dataMap[i]["adjavgnetincomeratio"] 
			if adjavgnetincomeratio == ""{
                if _,err := insert.Exec(i,nil); err!=nil{
					panic(err)
				}
			}else{
				nadjavgnetincomeratio,ok := convtofloat64(adjavgnetincomeratio)
				if ok == false{
					log.Fatal("convertion failed")
				}
				if _,err := insert.Exec(i,nadjavgnetincomeratio); err!=nil{
					panic(err)
				}
			}
		}
	}
	//将数据插入表industry
	case "industry":{
		insert, err := db.Prepare("INSERT INTO industry(year,increment,incrementrate,gdpincrement) VALUES(?,?,?,? )")
	    if err!= nil{
		    panic(err)
	    }
		defer insert.Close()
		for i:=1960; i<2019; i++{
			increment := dataMap[i]["increment"]
			nincrement,ok := convtofloat64(increment)
			if ok == false{
				log.Fatal("convertion failed")
			}
			incrementrate := dataMap[i]["incrementrate"]
			gdpincrement := dataMap[i]["gdpincrement"]
			if i == 1960{
				if _,err := insert.Exec(i,nincrement,nil,nil);err!=nil{
					panic(err)
				}
			}else{
				nincrementrate,ok := convtofloat64(incrementrate)
				if ok == false{
					log.Fatal("convertion failed")
				}
				ngdpincrement,ok := convtofloat64(gdpincrement)
				if ok == false{
					log.Fatal("convertion failed")
				}
				if _,err := insert.Exec(i,nincrement,nincrementrate,ngdpincrement); err != nil{
					panic(err)
				}
			}
		}
	}
	//将数据插入表importexport
	case "importexport":{
		insert, err := db.Prepare("INSERT INTO importexport(year,gdpcomdtdratio,manfexportcomdratio) VALUES(?,?,? )")
	    if err!= nil{
		    panic(err)
	    }
		defer insert.Close()

		for i:=1960; i<2019; i++{
			gdpcomdtdratio := dataMap[i]["gdpcomdtdratio"]
			manfexportcomdratio := dataMap[i]["manfexportcomdratio"]
			ngdpcomdtdratio,ok := convtofloat64(gdpcomdtdratio)
			if ok == false {
				log.Fatal("convertion failed")
			}
			if manfexportcomdratio == ""{
				if _,err := insert.Exec(i,ngdpcomdtdratio,nil); err != nil{
			        panic(err)
				}
			}else{
				nmanfexportcomdratio,ok := convtofloat64(manfexportcomdratio)
				if ok == false{
					log.Fatal("convertion failed")
				}
				if _,err := insert.Exec(i,ngdpcomdtdratio,nmanfexportcomdratio); err != nil{
					panic(err)
				}
			}
		}
	}
	default:{
		//
	}
    }
}

//将字符串转换成64位整数
func convtoint64(s string)(int64,bool){
	n,err := strconv.ParseInt(s,10,64)
	if err != nil{
       return 0,false 
	}
	return n,true
}

//将字符串转换成double类型
func convtofloat64(s string)(float64,bool){
	n,err := strconv.ParseFloat(s,64)
	if err != nil{
		return 0,false 
	}
	return n,true 
}
