// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherGiveaway {
    address public admin;
    uint256 public totalKupon = 0;

    // Modifier untuk membatasi akses hanya kepada admin
    modifier hanyaAdmin() {
        require(msg.sender == admin, "Aksi hanya dapat dilakukan oleh admin");
        _;
    }

    // Modifier untuk memeriksa apakah pemanggil adalah pemenang yang dipilih
    modifier adalahPemenang(uint256 kuponId) {
        require(bukuKupon[kuponId].pemenang == msg.sender, "Pemanggil bukan pemenang yang ditentukan");
        _;
    }

    // Acara untuk mencatat aktivitas
    event EtherDidonasikan(address indexed donatur, uint256 jumlah, uint256 kuponId);
    event PemenangDipilih(uint256 kuponId, address indexed pemenang);

    // Struct untuk menyimpan detail kupon
    struct KuponGiveaway {
        address donatur;
        uint256 jumlahEther;
        address pemenang;
        bool sudahDiklaim;
    }

    // Mapping untuk menyimpan semua kupon giveaway
    mapping(uint256 => KuponGiveaway) public bukuKupon;

    // Konstruktor untuk menetapkan admin
    constructor() {
        admin = msg.sender;
    }

    // Fungsi untuk mendonasikan Ether dan membuat kupon giveaway
    function buatDonasi() external payable {
        require(msg.value > 0, "Donasi harus lebih dari nol");

        // Menambahkan kupon giveaway baru
        bukuKupon[totalKupon] = KuponGiveaway({
            donatur: msg.sender,
            jumlahEther: msg.value,
            pemenang: address(0),
            sudahDiklaim: false
        });

        emit EtherDidonasikan(msg.sender, msg.value, totalKupon);
        totalKupon++;
    }

    // Fungsi admin untuk memilih pemenang untuk kupon tertentu
    function pilihPemenang(uint256 kuponId, address alamatPemenang) external hanyaAdmin {
        require(kuponId < totalKupon, "ID kupon tidak valid");
        require(bukuKupon[kuponId].pemenang == address(0), "Pemenang sudah dipilih sebelumnya");

        bukuKupon[kuponId].pemenang = alamatPemenang;
        emit PemenangDipilih(kuponId, alamatPemenang);
    }

    // Fungsi bagi pemenang untuk mengklaim Ether dari kupon
    function klaimKupon(uint256 kuponId) external adalahPemenang(kuponId) {
        require(kuponId < totalKupon, "ID kupon tidak valid");
        require(!bukuKupon[kuponId].sudahDiklaim, "Kupon ini sudah diklaim sebelumnya");

        uint256 jumlahHadiah = bukuKupon[kuponId].jumlahEther;
        bukuKupon[kuponId].sudahDiklaim = true;

        (bool terkirim, ) = msg.sender.call{value: jumlahHadiah}("");
        require(terkirim, "Transfer Ether gagal");
    }

    // Fungsi untuk melihat detail dari kupon tertentu
    function lihatKupon(uint256 kuponId) external view returns (address, uint256, address, bool) {
        require(kuponId < totalKupon, "ID kupon tidak valid");
        KuponGiveaway memory kupon = bukuKupon[kuponId];
        return (kupon.donatur, kupon.jumlahEther, kupon.pemenang, kupon.sudahDiklaim);
    }
}
