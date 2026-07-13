<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class MonthlyReportController extends Controller
{
    public function exportSalesPdf(Request $request)
    {
        $month = $request->input('month', now()->month);
        $year = $request->input('year', now()->year);

        $monthName = Carbon::createFromDate($year, $month, 1)->translatedFormat('F');

        $sales = Sale::with('product')
            ->whereMonth('tanggal_keluar', $month)
            ->whereYear('tanggal_keluar', $year)
            ->orderBy('tanggal_keluar', 'asc')
            ->get();

        $totalRevenue = $sales->sum('total_harga');
        $totalQty = $sales->sum('jumlah_terjual');

        $data = [
            'sales' => $sales,
            'month' => $month,
            'year' => $year,
            'monthName' => $monthName,
            'totalRevenue' => $totalRevenue,
            'totalQty' => $totalQty,
            'date' => now()->format('d F Y'),
        ];

        $pdf = Pdf::loadView('pdf.monthly_report', $data);

        return $pdf->stream("Laporan_Penjualan_{$monthName}_{$year}.pdf");
    }
}
