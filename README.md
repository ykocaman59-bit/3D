# Saklambaç 3D — Multiplayer + Ebe + Saklanma

Godot 4.x prototipi.

## Özellikler
- 8 oyuncuya kadar ENet multiplayer
- HOST / IP ile BAĞLAN
- Sunucu rastgele değil, ilk host oyuncuyu ebe olarak başlatır
- 90 saniyelik tur
- Ebe oyuncuları fiziksel yakınlıktan yakalar
- Saklanan oyuncular sadece saklanma alanlarına yakınken SAKLAN'a basabilir
- Saklanınca oyuncunun modeli görünmez
- Yakalayınca görünür ve elenir
- İki katlı ev, merdiven, odalar ve mobilyalar
- Mobil joystick, kamera sürükleme, koşma ve saklanma
- PC testinde WASD kullanılabilir

## Çalıştırma
1. Godot 4 ile project.godot'u aç.
2. Bir cihazda HOST'a bas.
3. Diğer cihazlarda host cihazın yerel IP'sini yazıp BAĞLAN'a bas.
4. Aynı Wi-Fi/LAN üzerinde port 7777 erişilebilir olmalıdır.

## Not
Bu, oynanabilir bir temel prototiptir. İnternet üzerinden gerçek sunucu, hesap sistemi, matchmaking, sesli sohbet, anti-cheat ve yüksek kaliteli 3D assetler ayrıca geliştirilmelidir.
