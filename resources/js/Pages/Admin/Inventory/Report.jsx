import React, { useState, useMemo } from 'react';
import { Head, Link } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { ChevronDown, ChevronUp, BarChart3, HelpCircle, ArrowUpRight } from 'lucide-react';
import { cardBg, cardCls, statusBadge, PageHeader } from '@/Lib/ui';

const statusDot = {
    'Segera Pesan': 'bg-rose-500 shadow-[0_0_8px_rgba(244,63,94,0.4)]',
    'Dalam Pemesanan': 'bg-blue-500 shadow-[0_0_8px_rgba(59,130,246,0.4)]',
    'Waspada': 'bg-amber-500 shadow-[0_0_8px_rgba(245,158,11,0.4)]',
    'Aman': 'bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.4)]',
};

const statusRowBg = {
    'Segera Pesan': 'hover:bg-rose-500/[0.02]',
    'Dalam Pemesanan': 'hover:bg-blue-500/[0.02]',
    'Waspada': 'hover:bg-amber-500/[0.02]',
    'Aman': 'hover:bg-emerald-500/[0.01]',
};

export default function InventoryReport({ report, user }) {
    const [filter, setFilter] = useState('all');
    const [expanded, setExpanded] = useState(null);

    const alertCount = report.filter(r => r.status_stok === 'Segera Pesan').length;

    const tabs = [
        { key: 'all',          label: 'Semua Produk',   count: report.length },
        { key: 'Segera Pesan', label: 'Kritis (ROP)',   count: report.filter(r => r.status_stok === 'Segera Pesan').length },
        { key: 'Waspada',      label: 'Waspada',        count: report.filter(r => r.status_stok === 'Waspada').length },
        { key: 'Aman',         label: 'Aman',           count: report.filter(r => r.status_stok === 'Aman').length },
    ];

    const filtered = useMemo(() =>
        filter === 'all' ? report : report.filter(r => r.status_stok === filter),
        [report, filter]
    );

    return (
        <AdminLayout user={user} alertCount={alertCount} title="Laporan ROP">
            <Head title="Laporan ROP — Budi Variasi" />

            {/* Page Header */}
            <PageHeader
                title="Laporan Perhitungan ROP & Regresi"
                subtitle="Hasil kalkulasi reorder point (ROP) berdasarkan data penjualan historis bulanan"
            />

            {/* Formula Info Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                {[
                    { formula: "Y' = a + bX", label: "Prediksi Penjualan Bulan Depan", desc: "Didapat melalui analisis tren Regresi Linear Sederhana." },
                    { formula: "d = Y' ÷ 30", label: "Permintaan Harian Rata-Rata (d)", desc: "Asumsi rata-rata siklus operasional 30 hari kalender." },
                    { formula: "ROP = (d × L) + SS", label: "Reorder Point / Batas Pemesanan", desc: "L = Lead Time supplier (hari), SS = Safety Stock (unit)." },
                ].map((f, idx) => (
                    <div
                        key={idx}
                        className={`${cardCls} p-5 bg-gradient-to-br from-slate-900/60 to-slate-950/20`}
                        style={{ backgroundColor: cardBg }}
                    >
                        <span className="inline-block text-[9px] font-bold text-blue-400 bg-blue-500/10 px-2 py-0.5 rounded-full uppercase tracking-wider mb-2">
                            Parameter {idx + 1}
                        </span>
                        <h4 className="text-white font-bold text-xs tracking-wide mb-1">{f.label}</h4>
                        <code className="block text-emerald-400 font-mono text-sm font-bold my-2 bg-slate-950/60 px-3 py-1.5 rounded-xl border border-slate-900 w-fit">
                            {f.formula}
                        </code>
                        <p className="text-slate-500 text-[10px] leading-relaxed mt-1 font-medium">{f.desc}</p>
                    </div>
                ))}
            </div>

            {/* Tab Filters */}
            <div className="flex gap-2 overflow-x-auto pb-1.5 mb-4">
                {tabs.map(t => (
                    <button
                        key={t.key}
                        onClick={() => setFilter(t.key)}
                        className={`px-4 py-2.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap ${
                            filter === t.key
                                ? 'bg-blue-600 text-white shadow-md shadow-blue-500/10'
                                : 'bg-slate-900 border border-slate-800 text-slate-400 hover:text-slate-255 hover:bg-slate-800'
                        }`}
                    >
                        {t.label}
                        <span className="ml-1.5 opacity-60">({t.count})</span>
                    </button>
                ))}
            </div>

            {/* Table */}
            <div className={cardCls} style={{ backgroundColor: cardBg }}>
                <div className="overflow-x-auto">
                    <table className="w-full text-xs">
                        <thead>
                            <tr className="border-b border-slate-900 bg-slate-900/10 text-slate-500 text-[10px] font-bold uppercase tracking-widest">
                                <th className="px-4 py-3.5 text-left font-bold">Produk</th>
                                <th className="px-3 py-3.5 text-center font-bold">n (Bln)</th>
                                <th className="px-4 py-3.5 text-left font-bold">Persamaan Regresi</th>
                                <th className="px-4 py-3.5 text-right font-bold">Prediksi (Y')</th>
                                <th className="px-4 py-3.5 text-right font-bold">Harian (d)</th>
                                <th className="px-3 py-3.5 text-center font-bold">L (Hari)</th>
                                <th className="px-3 py-3.5 text-center font-bold">SS (Unit)</th>
                                <th className="px-4 py-3.5 text-right font-bold">ROP (Batas)</th>
                                <th className="px-4 py-3.5 text-right font-bold">Stok</th>
                                <th className="px-4 py-3.5 text-center font-bold">Status</th>
                                <th className="px-3 py-3.5 text-center font-bold" style={{ width: '40px' }}></th>
                            </tr>
                        </thead>
                        <tbody>
                            {filtered.map((item, idx) => {
                                const badge = statusBadge[item.status_stok] ?? statusBadge['Aman'];
                                const dot = statusDot[item.status_stok] ?? statusDot['Aman'];
                                const rowBg = statusRowBg[item.status_stok] ?? '';
                                const exp = expanded === idx;

                                return (
                                    <React.Fragment key={item.id_barang}>
                                        <tr
                                            className={`border-b border-slate-900/60 last:border-0 transition-colors duration-200 ${rowBg} ${
                                                item.status_stok === 'Segera Pesan' ? 'bg-rose-500/[0.01]' : ''
                                            }`}
                                        >
                                            {/* Nama Produk */}
                                            <td className="px-4 py-4">
                                                <div className="flex items-center gap-2.5">
                                                    <span className={`w-2 h-2 rounded-full flex-shrink-0 ${dot}`} />
                                                    <div className="min-w-0">
                                                        <p className="text-slate-100 font-bold tracking-wide truncate max-w-[150px]">{item.nama_barang}</p>
                                                        <p className="text-slate-500 text-[10px] mt-0.5 font-medium">{item.kategori}</p>
                                                    </div>
                                                </div>
                                            </td>

                                            {/* n (Bulan) */}
                                            <td className="px-3 py-4 text-center font-mono font-bold text-slate-500">
                                                {item.n}
                                            </td>

                                            {/* Persamaan */}
                                            <td className="px-4 py-4">
                                                {item.error ? (
                                                    <span className="text-rose-400 font-semibold text-[10px]">Data tidak cukup</span>
                                                ) : (
                                                    <code className="text-slate-400 font-mono font-bold bg-slate-950/40 px-2 py-1 rounded-lg border border-slate-900">
                                                        {item.persamaan}
                                                    </code>
                                                )}
                                            </td>

                                            {/* Y' Prediksi */}
                                            <td className="px-4 py-4 text-right font-mono font-bold text-slate-200">
                                                {item.y_prediksi ? item.y_prediksi.toFixed(1) : '—'}
                                            </td>

                                            {/* d harian */}
                                            <td className="px-4 py-4 text-right font-mono text-slate-500">
                                                {item.d ? item.d.toFixed(3) : '—'}
                                            </td>

                                            {/* Lead Time L */}
                                            <td className="px-3 py-4 text-center font-mono text-slate-400 font-bold">
                                                {item.lead_time}
                                            </td>

                                            {/* Safety Stock SS */}
                                            <td className="px-3 py-4 text-center font-mono text-slate-400 font-bold">
                                                {item.safety_stock}
                                            </td>

                                            {/* ROP */}
                                            <td className="px-4 py-4 text-right font-mono font-extrabold text-blue-400 text-sm">
                                                {item.rop}
                                            </td>

                                            {/* Stok */}
                                            <td className="px-4 py-4 text-right">
                                                <span className={`font-bold ${item.stok_saat_ini <= item.rop ? 'text-rose-400' : 'text-slate-200'}`}>
                                                    {item.stok_saat_ini}
                                                </span>
                                                <span className="text-slate-500 text-[10px] ml-1 font-semibold">{item.satuan}</span>
                                            </td>

                                            {/* Status */}
                                            <td className="px-4 py-4 text-center">
                                                <span className={badge}>
                                                    {item.status_stok}
                                                </span>
                                            </td>

                                            {/* Expanded Button */}
                                            <td className="px-3 py-4 text-center">
                                                <button
                                                    onClick={() => setExpanded(exp ? null : idx)}
                                                    className="p-1.5 text-slate-500 hover:text-slate-300 hover:bg-slate-800 rounded-lg transition-all"
                                                >
                                                    {exp ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
                                                </button>
                                            </td>
                                        </tr>

                                        {/* Expanded Detail Panel */}
                                        {exp && (
                                            <tr className="bg-slate-950/30">
                                                <td colSpan={11} className="px-6 py-4 border-b border-slate-900/40">
                                                    <div className="flex items-center justify-between mb-3">
                                                        <h5 className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Detail Tahapan Perhitungan</h5>
                                                        <Link
                                                            href={`/admin/inventory/${item.id_barang}`}
                                                            className="inline-flex items-center gap-0.5 text-[10px] font-bold text-blue-400 hover:text-blue-300 transition-colors"
                                                        >
                                                            Lihat Grafik Regresi & Nilai Deviasi <ArrowUpRight className="w-3.5 h-3.5" />
                                                        </Link>
                                                    </div>
                                                    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                                                        {[
                                                            { label: 'Koefisien Persamaan (Y)', val: item.persamaan },
                                                            { label: "Prediksi Penjualan (Y')", val: `${item.y_prediksi?.toFixed(2)} unit/bulan` },
                                                            { label: "Permintaan Rata-Rata (d)", val: `${item.d?.toFixed(4)} unit/hari` },
                                                            { label: 'Rumus Reorder Point (ROP)', val: `(${item.d?.toFixed(3)} × ${item.lead_time}) + ${item.safety_stock} = ${item.rop} unit` },
                                                        ].map((c, i) => (
                                                            <div key={i} className="bg-slate-900/60 border border-slate-850 p-3 rounded-2xl">
                                                                <p className="text-[9px] font-bold text-slate-500 uppercase tracking-wider mb-1">{c.label}</p>
                                                                <p className="text-slate-200 font-mono text-xs font-bold truncate">{c.val}</p>
                                                            </div>
                                                        ))}
                                                    </div>
                                                </td>
                                            </tr>
                                        )}
                                    </React.Fragment>
                                );
                            })}
                        </tbody>
                    </table>
                </div>
            </div>
        </AdminLayout>
    );
}
