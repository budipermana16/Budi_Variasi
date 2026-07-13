<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Purchase Order {{ $po_number }}</title>
    <style>
        body { font-family: sans-serif; font-size: 14px; line-height: 1.5; color: #333; }
        .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #333; padding-bottom: 10px; }
        .header h1 { margin: 0; font-size: 24px; text-transform: uppercase; }
        .header p { margin: 5px 0 0; color: #666; }
        .info-table { width: 100%; margin-bottom: 30px; }
        .info-table td { vertical-align: top; width: 50%; }
        .details-table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        .details-table th, .details-table td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        .details-table th { background-color: #f8f9fa; }
        .footer { margin-top: 50px; text-align: right; }
        .signature { margin-top: 80px; text-align: right; margin-right: 50px;}
    </style>
</head>
<body>

    <div class="header">
        <h1>Budi Variasi Mobil</h1>
        <p>Jl. Contoh Alamat Ngawi, Jawa Timur | Telp: 0812-XXXX-XXXX</p>
    </div>

    <table class="info-table">
        <tr>
            <td>
                <strong>Kepada Yth:</strong><br>
                Supplier: {{ $supplier ? $supplier->nama_supplier : 'Belum Ditentukan' }}<br>
                Kontak: {{ $supplier ? $supplier->kontak_person : '-' }}<br>
                Alamat: {{ $supplier ? $supplier->alamat : '-' }}
            </td>
            <td style="text-align: right;">
                <strong>Tanggal:</strong> {{ $date }}<br>
                <strong>No. PO:</strong> {{ $po_number }}
            </td>
        </tr>
    </table>

    <h3>Detail Pesanan (Rekomendasi ROP)</h3>
    <table class="details-table">
        <thead>
            <tr>
                <th>No</th>
                <th>Nama Barang</th>
                <th>Kategori</th>
                <th>Stok Saat Ini</th>
                <th>Rekomendasi ROP</th>
                <th>Jumlah Dipesan</th>
                <th>Satuan</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>1</td>
                <td>{{ $product->nama_barang }}</td>
                <td>{{ $product->kategori }}</td>
                <td>{{ $product->stok_saat_ini }}</td>
                <td>{{ $inventoryControl ? $inventoryControl->reorder_point : '-' }}</td>
                <td>
                    <strong>
                        @if($inventoryControl && $inventoryControl->reorder_point > $product->stok_saat_ini)
                            {{ $inventoryControl->reorder_point - $product->stok_saat_ini }}
                        @else
                            {{ $inventoryControl ? $inventoryControl->reorder_point : 10 }}
                        @endif
                    </strong>
                </td>
                <td>{{ $product->satuan }}</td>
            </tr>
        </tbody>
    </table>

    <p style="font-size: 12px; color: #666;">
        <em>*Catatan: Jumlah dipesan merupakan estimasi berdasarkan perhitungan algoritma Reorder Point (ROP) untuk mencapai batas aman stok.</em>
    </p>

    <div class="footer">
        <p>Ngawi, {{ $date }}</p>
        <p>Hormat Kami,</p>
        <div class="signature">
            <p><strong>Admin Gudang / Owner</strong></p>
        </div>
    </div>

</body>
</html>
