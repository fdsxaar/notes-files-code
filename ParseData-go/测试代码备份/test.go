package main

import (
  "github.com/etree"
  "fmt"
  //"database/sql"
  //_"github.com/go-sql-driver/mysql"
)

func main(){
  //db, err := sql.Open("mysql", "user:password@/dbname")

  doc := etree.NewDocument()
  if err := doc.ReadFromFile("test.xml"); err != nil {
    panic(err)
  }

  root := doc.SelectElement("Root")
  fmt.Println("ROOT element:", root.Tag)

  data := root.SelectElement("data")
  fmt.Println("data element:", data.Tag)

  fmt.Println(data.FindElement("//record/field[@key='fuck']").Text())
  
  fucks := data.FindElements("//record/field[@key='fuck']")
  for _,fk := range fucks{
    pfk := fk.Parent()
    idx0 := pfk.FindElement("field[@name='Value']")
    //idxo := pfk.FindElement("filed[1]")
    fmt.Println("fuck field",idx0.Text())
    fmt.Println("fuck field",fk.Text())
  }
  /*
  records := data.SelectElements("record") 
  for _,record := range records{
    for _,field := range record.SelectElements("field"){
      fmt.Println("record element:", field.Tag)
    }
  }*/

}

