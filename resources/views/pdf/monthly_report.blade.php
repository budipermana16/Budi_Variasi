<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Laporan Penjualan - {{ $monthName }} {{ $year }}</title>
    <style>
        body { font-family: sans-serif; font-size: 12px; line-height: 1.4; color: #333; }
        .header { text-align: center; margin-bottom: 20px; border-bottom: 2px solid #333; padding-bottom: 8px; }
        .header h1 { margin: 0; font-size: 20px; text-transform: uppercase; }
        .header p { margin: 3px 0 0; color: #666; font-size: 11px; }
        .title { text-align: center; margin-bottom: 20px; text-transform: uppercase; }
        .title h2 { margin: 0; font-size: 15px; }
        .title p { margin: 4px 0 0; font-size: 12px; color: #555; }
        .table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        .table th, .table td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        .table th { background-color: #f2f2f2; font-weight: bold; }
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .total-box { margin-top: 10px; margin-bottom: 20px; width: 100%; }
        .total-box td { font-weight: bold; padding: 6px; border: none; }
        .footer { margin-top: 40px; }
        .footer-table { width: 100%; border: none; }
        .footer-table td { border: none; width: 50%; vertical-align: top; }
        .signature { margin-top: 60px; font-weight: bold; }
    </style>
</head>
<body>

    <div class="header">
        <h1>Budi Variasi Mobil</h1>
        <p>Jl. Ring Road Barat, Ngawi, Jawa Timur | Telp: 0812-3456-7890</p>
    </div>

    <div class="title">
        <h2>Laporan Penjualan Bulanan</h2>
        <p>Periode: {{ $monthName }} {{ $year }}</p>
    </div>

    <table class="table">
        <thead>
            <tr>
                <th class="text-center" style="width: 5%;">No</th>
                <th style="width: 15%;">Tanggal</th>
                <th style="width: 35%;">Nama Barang</th>
                <th style="width: 15%;">Kategori</th>
                <th class="text-right" style="width: 10%;">Jumlah</th>
                <th style="width: 10%;">Satuan</th>
                <th class="text-right" style="width: 15%;">Total Harga</th>
            </tr>
        </thead>
        <tbody>
            @forelse($sales as $idx => $sale)
                <tr>
                    <td class="text-center">{{ $idx + 1 }}</td>
                    <td>{{ $sale->tanggal_keluar->format('d/m/Y') }}</td>
                    <td>{{ $sale->product ? $sale->product->nama_barang : 'Barang Terhapus' }}</td>
                    <td>{{ $sale->product ? $sale->product->kategori : '-' }}</td>
                    <td class="text-right">{{ $sale->jumlah_terjual }}</td>
                    <td>{{ $sale->product ? $sale->product->satuan : '-' }}</td>
                    <td class="text-right">Rp {{ number_format($sale->total_harga, 0, ',', '.') }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="7" class="text-center" style="padding: 20px; color: #777;">
                        Tidak ada data penjualan pada periode ini.
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <table style="width: 100%; border: 1px solid #ccc; background-color: #fafafa; padding: 10px; border-radius: 4px;">
        <tr>
            <td style="font-weight: bold; width: 40%;">Total Unit Terjual:</td>
            <td style="font-size: 14px; font-weight: bold; color: #2563eb;">{{ $totalQty }} unit</td>
            <td style="font-weight: bold; width: 30%; text-align: right;">Total Pendapatan:</td>
            <td style="font-size: 14px; font-weight: bold; color: #16a34a; text-align: right;">
                Rp {{ number_format($totalRevenue, 0, ',', '.') }}
            </td>
        </tr>
    </table>

    <div class="footer">
        <table class="footer-table">
            <tr>
                <td></td>
                <td class="text-right">
                    <p>Ngawi, {{ $date }}</p>
                    <p>Hormat Kami,</p>
                    <div class="signature">
                        <p>Owner / Pimpinan Toko</p>
                    </div>
                </td>
            </tr>
        </table>
    </div>

</body>
</html>
