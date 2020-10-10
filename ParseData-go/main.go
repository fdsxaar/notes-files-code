package main

import (
  "database/sql"
  _"github.com/go-sql-driver/mysql"
)

func main(){
  //打开数据库handle
  db, err := sql.Open("mysql", "root:lyy5372963@/Datacn?charset=utf8mb4,utf8&timeout=5000ms&readTimeout=3000ms&writeTimeout=5000ms")
  if err != nil {
    panic(err.Error()) 
  }
  defer db.Close()
  
  err = db.Ping()
  if err != nil {
    panic(err.Error()) 
  }

  //初始化dataMap,存储从xml文件解析到的数据
  dataMap := make(map[int]map[string]string)
  for i:=1960; i<2019; i++{                 //1960年到2018年数据
    dataMap[i] = make(map[string]string) 
  }

  cnmap := codenamemap()
  
  for _,v := range cnmap{
    parseAndSaveData(v,dataMap)
  }

  //组装数据，将数据拼成表的一行,插入表中
  for k,v := range cnmap{
    assemAndInsertData(db,dataMap,k,v)
  }
}

