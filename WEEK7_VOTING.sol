// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SistemPemilu {
    // Enum untuk tahap pemilu
    enum TahapPemilihan { TidakAktif, Aktif, Selesai }
    TahapPemilihan public tahapSaatIni;

    // Definisi struct untuk Peserta dan Pemilih
    struct Peserta {
        uint256 idKandidat;
        string namaKandidat;
        uint256 totalSuara;
    }

    struct DetailPemilih {
        bool sudahMemilih;
        uint256 kandidatDipilih;
    }

    // Variabel state
    address public pemilik;
    uint256 public totalKandidat;
    mapping(uint256 => Peserta) public daftarKandidat;
    mapping(address => DetailPemilih) public daftarPemilih;

    // Acara
    event KandidatBaru(uint256 idKandidat, string nama);
    event PemilihTerdaftar(address pemilih);
    event SuaraDiberikan(address pemilih, uint256 idKandidat);
    event PemiluDiaktifkan();
    event PemiluDinonaktifkan();

    // Modifier untuk kontrol akses
    modifier hanyaPemilik() {
        require(msg.sender == pemilik, "Akses hanya untuk pemilik kontrak");
        _;
    }

    modifier pemiluSedangBerlangsung() {
        require(tahapSaatIni == TahapPemilihan.Aktif, "Pemilu tidak sedang aktif");
        _;
    }

    modifier belumMemilih() {
        require(!daftarPemilih[msg.sender].sudahMemilih, "Anda sudah memberikan suara");
        _;
    }

    constructor() {
        pemilik = msg.sender;
        tahapSaatIni = TahapPemilihan.TidakAktif;
    }

    // Fungsi untuk mendaftarkan kandidat baru
    function daftarKandidatBaru(string calldata nama) external hanyaPemilik {
        totalKandidat++;
        daftarKandidat[totalKandidat] = Peserta(totalKandidat, nama, 0);
        emit KandidatBaru(totalKandidat, nama);
    }

    // Fungsi untuk mendaftarkan pemilih baru
    function otorisasiPemilih(address alamatPemilih) external hanyaPemilik {
        daftarPemilih[alamatPemilih] = DetailPemilih(false, 0);
        emit PemilihTerdaftar(alamatPemilih);
    }

    // Fungsi untuk memulai proses pemilu
    function aktifkanPemilu() external hanyaPemilik {
        require(tahapSaatIni == TahapPemilihan.TidakAktif, "Pemilu sudah dimulai atau selesai");
        tahapSaatIni = TahapPemilihan.Aktif;
        emit PemiluDiaktifkan();
    }

    // Fungsi untuk mengakhiri proses pemilu
    function nonaktifkanPemilu() external hanyaPemilik {
        require(tahapSaatIni == TahapPemilihan.Aktif, "Pemilu tidak sedang aktif");
        tahapSaatIni = TahapPemilihan.Selesai;
        emit PemiluDinonaktifkan();
    }

    // Fungsi untuk memberikan suara
    function berikanSuara(uint256 idKandidat) external pemiluSedangBerlangsung belumMemilih {
        require(daftarKandidat[idKandidat].idKandidat != 0, "ID kandidat tidak valid");

        daftarPemilih[msg.sender].sudahMemilih = true;
        daftarPemilih[msg.sender].kandidatDipilih = idKandidat;
        daftarKandidat[idKandidat].totalSuara += 1;

        emit SuaraDiberikan(msg.sender, idKandidat);
    }

    // Fungsi untuk mendapatkan total suara dari kandidat tertentu
    function totalSuaraKandidat(uint256 idKandidat) external view returns (uint256) {
        return daftarKandidat[idKandidat].totalSuara;
    }

    // Fungsi untuk memeriksa tahap pemilu saat ini
    function periksaTahapPemilu() external view returns (string memory) {
        if (tahapSaatIni == TahapPemilihan.TidakAktif) return "Tidak Aktif";
        if (tahapSaatIni == TahapPemilihan.Aktif) return "Aktif";
        if (tahapSaatIni == TahapPemilihan.Selesai) return "Selesai";
        return "";
    }
}
