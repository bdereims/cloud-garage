package main

import "fmt"

func main() {
	var subnet uint16
	var x uint16
	var y uint16
	var u uint16
	var v uint16
	x = 0
	y = 0 
	for i := 0; i <= 4079; i++ {
		fmt.Println("Subnet:", i)
		for j := 0; j <= 15; j++ {
			subnet = x + y
			u = subnet & 65280
			u = u >> 8 
			v = subnet & 255 - 15 
			fmt.Printf("%#d %#d ; %#12b %#4b ; %#16b ; %#16b %#16b \n", x, y, x, y, subnet, u, v)
			//fmt.Printf("10.%#d.%#d.0/24 \n", u, v)
			y = y + 1
		}
		y = 0
		x = x + 16 
		fmt.Printf("10.%#d.%#d.0/24 \n", u, v)
	}
}
