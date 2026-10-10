package main

import "fmt"

func main() {
	var koin, koin_emas, koin_perak, koin_tembaga int
	fmt.Scan(&koin)
	koin_emas = koin / 9
	koin_perak = (koin % 9) / 3
	koin_tembaga = (koin % 9) % 3
	fmt.Println("Koin Emas:", koin_emas, "Koin Perak:", koin_perak, "Koin Tembaga:", koin_tembaga)

}
