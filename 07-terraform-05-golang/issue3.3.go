package main

import "fmt"

func main() {
	var x int
	for i := 1; i < 100; i++ {
		x = i % 3   //находим остаток от деления
		if x == 0 { // если остаток от деления равен нулю - выводи число на экран
			fmt.Println(i)
		}
	}
}
