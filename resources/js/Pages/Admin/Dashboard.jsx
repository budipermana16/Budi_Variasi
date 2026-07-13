import React, { useState } from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import {
    Package, AlertTriangle, ShoppingCart, Clock,
    ArrowUpRight, ArrowRight, TrendingUp, Printer
} from 'lucide-react';
import {
    LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, ReferenceLine
} from 'recharts';
import { cardBg, cardCls, statusBadge, PageHeader, BtnPrimary } from '@/Lib/ui';

const statusDot = {
    'Segera Pesan': 'bg-rose-500 shadow-[0_0_8px_rgba(244,63,94,0.5)]',
    'Dalam Pemesanan': 'bg-blue-500 shadow-[0_0_8px_rgba(59,130,246,0.5)]',
    'Waspada': 'bg-amber-500 shadow-[0_0_8px_rgba(245,158,11,0.5)]',
    'Aman': 'bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.5)]',
};

const statusRowBg = {
    'Segera Pesan': 'hover:bg-rose-500/[0.02]',
    'Dalam Pemesanan': 'hover:bg-blue-500/[0.02]',
    'Waspada': 'hover:bg-amber-500/[0.02]',
    'Aman': 'hover:bg-emerald-500/[0.01]',
};

function KpiCard({ icon: Icon, label, value, sub, accent }) {
    const accentMap = {
        blue:    { grad: 'from-blue-600/10 to-indigo-600/5', border: 'border-blue-500/20', text: 'text-blue-400', glow: 'shadow-blue-500/5' },
        red:     { grad: 'from-rose-600/10 to-red-600/5',    border: 'border-rose-500/20', text: 'text-rose-400', glow: 'shadow-rose-500/5' },
        amber:   { grad: 'from-amber-600/10 to-orange-600/5',border: 'border-amber-500/20',text: 'text-amber-400',glow: 'shadow-amber-500/5' },
        emerald: { grad: 'from-emerald-600/10 to-teal-600/5',border: 'border-emerald-500/20',text: 'text-emerald-400',glow: 'shadow-emerald-500/5' },
    };
    const c = accentMap[accent] ?? accentMap.blue;

    return (
        <div
            className={`relative p-5 rounded-3xl border border-slate-800/60 shadow-lg ${c.glow} overflow-hidden bg-gradient-to-br ${c.grad} backdrop-blur-md transition-all duration-300 hover:-translate-y-0.5`}
        >
            <div className="flex items-center justify-between mb-3">
                <p className="text-slate-400 text-xs font-semibold tracking-wide uppercase">{label}</p>
                <div className={`p-1.5 rounded-lg bg-slate-900/60 border ${c.border}`}>
                    <Icon className={`w-3.5 h-3.5 ${c.text}`} />
                </div>
            </div>
            <div className="flex items-baseline gap-1.5">
                <span className="text-2xl font-extrabold text-white tracking-tight">{value}</span>
                {sub && <span className="text-slate-500 text-[10px] font-bold uppercase">{sub}</span>}
            </div>
        </div>
    );
}

export default function Dashboard({ inventory, stats, chartData, user, currentMonth, currentYear }) {
    const [hoveredRow, setHoveredRow] = useState(null);
    const [selectedMonth, setSelectedMonth] = useState(currentMonth ?? (new Date().getMonth() + 1));
    const [selectedYear, setSelectedYear] = useState(currentYear ?? new Date().getFullYear());
    const alertCount = stats.segera_pesan;

    const getStockRatio = (stok, rop) => {
        if (rop === 0) return 100;
        return Math.min(100, Math.round((stok / (rop * 1.5)) * 100));
    };

    const handleMonthChange = (month) => {
        setSelectedMonth(month);
        router.get('/admin/dashboard', { month: month, year: selectedYear }, { preserveScroll: true, preserveState: true });
    };

    const handleYearChange = (year) => {
        setSelectedYear(year);
        router.get('/admin/dashboard', { month: selectedMonth, year: year }, { preserveScroll: true, preserveState: true });
    };

    const handleUpdateStatus = (inventoryControlId) => {
        router.put(`/admin/inventory/${inventoryControlId}/status`, {
            status_stok: 'Dalam Pemesanan'
        }, { preserveScroll: true });
    };

    const chartLines = chartData?.data ?? [];

    return (
        <AdminLayout user={user} alertCount={alertCount} title="Dashboard">
            <Head title="Dashboard — Budi Variasi" />

            {/* Alert Banner */}
            {alertCount > 0 && user?.role === 'owner' && (
                <div className="mb-6 flex items-center justify-between bg-rose-500/5 border border-rose-500/10 rounded-2xl px-4 py-3 shadow-md shadow-rose-950/5">
                    <div className="flex items-center gap-2.5 min-w-0">
                        <AlertTriangle className="w-4 h-4 text-rose-400 flex-shrink-0 animate-bounce" />
                        <p className="text-rose-300 text-xs font-semibold truncate">
                            Peringatan: <span className="font-extrabold text-white">{alertCount} produk</span> berada di bawah batas Reorder Point (ROP)!
                        </p>
                    </div>
                    <Link href="/admin/inventory/report" className="text-rose-400 hover:text-white text-xs font-bold flex items-center gap-1 transition-colors flex-shrink-0 ml-2">
                        Buka Laporan <ArrowRight className="w-3.5 h-3.5" />
                    </Link>
                </div>
            )}

            {/* Page Header */}
            <PageHeader
                title="Ringkasan Sistem & Peramalan ROP"
                subtitle="Selamat datang di panel admin inventory control Budi Variasi Mobil"
                action={
                    <div className="flex items-center gap-2 flex-wrap">
                        {/* Pilih Bulan & Tahun */}
                        <div className="flex items-center gap-1 bg-slate-900/60 border border-slate-800 p-1.5 rounded-xl">
                            <select
                                value={selectedMonth}
                                onChange={e => handleMonthChange(parseInt(e.target.value))}
                                className="bg-transparent border-0 text-slate-300 text-xs font-semibold focus:ring-0 focus:outline-none cursor-pointer pr-8 py-1"
                            >
                                <option value="1" className="bg-slate-950 text-white">Januari</option>
                                <option value="2" className="bg-slate-950 text-white">Februari</option>
                                <option value="3" className="bg-slate-950 text-white">Maret</option>
                                <option value="4" className="bg-slate-950 text-white">April</option>
                                <option value="5" className="bg-slate-950 text-white">Mei</option>
                                <option value="6" className="bg-slate-950 text-white">Juni</option>
                                <option value="7" className="bg-slate-950 text-white">Juli</option>
                                <option value="8" className="bg-slate-950 text-white">Agustus</option>
                                <option value="9" className="bg-slate-950 text-white">September</option>
                                <option value="10" className="bg-slate-950 text-white">Oktober</option>
                                <option value="11" className="bg-slate-950 text-white">November</option>
                                <option value="12" className="bg-slate-950 text-white">Desember</option>
                            </select>

                            <select
                                value={selectedYear}
                                onChange={e => handleYearChange(parseInt(e.target.value))}
                                className="bg-transparent border-0 text-slate-300 text-xs font-semibold focus:ring-0 focus:outline-none cursor-pointer pr-8 py-1 border-l border-slate-800/80 pl-2"
                            >
                                <option value="2024" className="bg-slate-950 text-white">2024</option>
                                <option value="2025" className="bg-slate-950 text-white">2025</option>
                                <option value="2026" className="bg-slate-950 text-white">2026</option>
                                <option value="2027" className="bg-slate-950 text-white">2027</option>
                                <option value="2028" className="bg-slate-950 text-white">2028</option>
                            </select>
                        </div>

                        {/* Tombol Cetak Laporan Bulanan */}
                        <a
                            href={`/admin/sales/monthly-report/pdf?month=${selectedMonth}&year=${selectedYear}`}
                            target="_blank"
                            className="inline-flex items-center gap-1.5 text-xs font-bold text-slate-300 hover:text-white px-3.5 py-2.5 bg-slate-900 border border-slate-800 rounded-xl hover:bg-slate-800 transition-all shadow-md"
                        >
                            <Printer className="w-4 h-4 text-blue-400" />
                            Cetak Laporan (PDF)
                        </a>

                        <BtnPrimary href="/admin/sales/create" color="blue">
                            + Catat Penjualan
                        </BtnPrimary>
                    </div>
                }
            />

            {/* KPI Cards Grid */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
                <KpiCard icon={Package}       label="Total Produk"        value={stats.total_produk}    accent="blue" />
                <KpiCard icon={AlertTriangle} label="Stok Kritis (ROP)"   value={stats.segera_pesan}    accent="red"  />
                <KpiCard icon={Clock}         label="Stok Waspada"        value={stats.waspada}          accent="amber" />
                <KpiCard icon={ShoppingCart}  label="Penjualan Bulan Ini" value={stats.total_penjualan} sub="unit" accent="emerald" />
            </div>

            {/* Graph & Chart Section */}
            {chartData && (
                <div
                    className={`${cardCls} p-6 mb-8`}
                    style={{ backgroundColor: cardBg }}
                >
                    <div className="mb-6">
                        <span className="inline-block text-[9px] font-bold text-blue-400 bg-blue-500/10 px-2 py-0.5 rounded-full uppercase tracking-wider mb-2">
                            {chartData.badge}
                        </span>
                        <h3 className="text-white font-bold text-sm tracking-wide">
                            {chartData.title}
                        </h3>
                        <p className="text-slate-500 text-xs mt-0.5">
                            {chartData.subtitle}
                        </p>
                    </div>
                    <div className="h-60">
                        <ResponsiveContainer width="100%" height="100%">
                            <LineChart data={chartLines} margin={{ top: 5, right: 10, bottom: 5, left: -25 }}>
                                <CartesianGrid strokeDasharray="3 3" stroke="#ffffff03" vertical={false} />
                                <XAxis dataKey="label" stroke="#475569" tick={{ fill: '#64748b', fontSize: 10 }} axisLine={false} tickLine={false} />
                                <YAxis stroke="#475569" tick={{ fill: '#64748b', fontSize: 10 }} axisLine={false} tickLine={false} />
                                <Tooltip
                                    contentStyle={{ backgroundColor: '#0b1329', borderColor: '#1e293b', borderRadius: '16px', boxShadow: '0 10px 25px -5px rgba(0,0,0,0.5)' }}
                                    itemStyle={{ color: '#fff', fontSize: '11px', fontWeight: 'bold' }}
                                    labelStyle={{ color: '#64748b', fontSize: '10px', fontWeight: 'semibold', marginBottom: '4px' }}
                                />
                                <Line type="monotone" dataKey="total_terjual" name="Total Terjual (Unit)" stroke="#3b82f6" strokeWidth={3} dot={{ r: 4, fill: '#0b1329', strokeWidth: 2 }} activeDot={{ r: 6, fill: '#3b82f6', stroke: '#fff' }} animationDuration={1000} />
                            </LineChart>
                        </ResponsiveContainer>
                    </div>
                </div>
            )}

            {/* Table Section */}
            <div className="space-y-4">
                <div className="flex items-center justify-between">
                    <div>
                        <h3 className="text-white font-bold text-sm tracking-wide">Status Inventori & Pemesanan Ulang</h3>
                        <p className="text-slate-500 text-xs mt-0.5">Daftar stok barang, ambang batas PO, dan rekomendasi pemesanan</p>
                    </div>
                </div>

                <div className={cardCls} style={{ backgroundColor: cardBg }}>
                    <div className="overflow-x-auto">
                        <table className="w-full text-xs">
                            <thead>
                                <tr className="border-b border-slate-900 bg-slate-900/10 text-slate-500 text-[10px] font-bold uppercase tracking-widest">
                                    <th className="px-5 py-3.5 text-left font-bold">Nama Barang</th>
                                    <th className="px-5 py-3.5 text-right font-bold">Sisa Stok</th>
                                    <th className="px-5 py-3.5 text-right font-bold">Ambang ROP</th>
                                    <th className="px-5 py-3.5 text-right font-bold">Prediksi/Bln</th>
                                    <th className="px-5 py-3.5 text-center font-bold">Rasio Stok</th>
                                    <th className="px-5 py-3.5 text-center font-bold">Status</th>
                                    <th className="px-5 py-3.5 text-center font-bold" style={{ width: '140px' }}>Aksi PO</th>
                                </tr>
                            </thead>
                            <tbody>
                                {inventory.map((item, idx) => {
                                    const badgeCls = statusBadge[item.status_stok] ?? statusBadge['Aman'];
                                    const dot = statusDot[item.status_stok] ?? statusDot['Aman'];
                                    const rowBg = statusRowBg[item.status_stok] ?? '';
                                    const ratio = getStockRatio(item.stok_saat_ini, item.rop);
                                    const isHovered = hoveredRow === idx;

                                    return (
                                        <tr
                                            key={item.id_barang}
                                            onMouseEnter={() => setHoveredRow(idx)}
                                            onMouseLeave={() => setHoveredRow(null)}
                                            className={`border-b border-slate-900/60 last:border-0 transition-colors duration-200 ${rowBg} ${isHovered ? 'bg-slate-900/40' : ''}`}
                                        >
                                            {/* Nama Barang */}
                                            <td className="px-5 py-4">
                                                <div className="flex items-center gap-3">
                                                    <span className={`w-2 h-2 rounded-full flex-shrink-0 ${dot}`} />
                                                    <div className="min-w-0">
                                                        <p className="text-slate-100 font-bold tracking-wide truncate">{item.nama_barang}</p>
                                                        <p className="text-slate-500 text-[10px] mt-0.5 font-medium">{item.kategori}</p>
                                                    </div>
                                                </div>
                                            </td>

                                            {/* Sisa Stok */}
                                            <td className="px-5 py-4 text-right">
                                                <span className={`font-bold ${item.stok_saat_ini <= item.rop && item.status_stok !== 'Dalam Pemesanan' ? 'text-rose-400' : 'text-slate-200'}`}>
                                                    {item.stok_saat_ini}
                                                </span>
                                                <span className="text-slate-500 text-[10px] ml-1 font-semibold">{item.satuan}</span>
                                            </td>

                                            {/* Ambang ROP */}
                                            <td className="px-5 py-4 text-right font-mono font-bold text-slate-400">
                                                {item.rop}
                                            </td>

                                            {/* Prediksi */}
                                            <td className="px-5 py-4 text-right font-mono text-slate-500">
                                                {item.prediksi_bulan_depan > 0 ? `≈${item.prediksi_bulan_depan}` : '—'}
                                            </td>

                                            {/* Progress Bar Rasio */}
                                            <td className="px-5 py-4">
                                                <div className="flex items-center gap-2 justify-center max-w-[120px] mx-auto">
                                                    <div className="w-16 h-1.5 bg-slate-900 rounded-full overflow-hidden">
                                                        <div
                                                            className={`h-full rounded-full transition-all duration-700 ${
                                                                ratio <= 33 ? 'bg-rose-500' :
                                                                ratio <= 66 ? 'bg-amber-500' : 'bg-emerald-500'
                                                            }`}
                                                            style={{ width: `${ratio}%` }}
                                                        />
                                                    </div>
                                                    <span className="text-[10px] text-slate-500 font-bold w-7 text-right">{ratio}%</span>
                                                </div>
                                            </td>

                                            {/* Status Badge */}
                                            <td className="px-5 py-4 text-center">
                                                <span className={badgeCls}>
                                                    {item.status_stok}
                                                </span>
                                            </td>

                                            {/* Actions */}
                                            <td className="px-5 py-4 text-center whitespace-nowrap">
                                                <div className="flex justify-center gap-1.5 items-center">
                                                    {item.status_stok === 'Segera Pesan' && item.id_control && (
                                                        <>
                                                            <button
                                                                onClick={() => handleUpdateStatus(item.id_control)}
                                                                className="px-2 py-1 bg-blue-500/10 text-blue-400 hover:bg-blue-500/20 text-[10px] rounded-lg border border-blue-500/20 transition-all font-bold"
                                                                title="Tandai Sudah Dipesan ke Supplier"
                                                            >
                                                                On Order
                                                            </button>
                                                            <a
                                                                href={`/admin/purchase-order/${item.id_barang}/pdf`}
                                                                target="_blank"
                                                                className="px-2 py-1 bg-slate-900 text-slate-300 hover:bg-slate-800 text-[10px] rounded-lg border border-slate-800 transition-all font-bold"
                                                                title="Cetak Surat Purchase Order"
                                                            >
                                                                Cetak PO
                                                            </a>
                                                        </>
                                                    )}

                                                    {item.status_stok === 'Dalam Pemesanan' && item.id_control && (
                                                        <a
                                                            href={`/admin/purchase-order/${item.id_barang}/pdf`}
                                                            target="_blank"
                                                            className="px-2.5 py-1 bg-slate-900 text-slate-300 hover:bg-slate-800 text-[10px] rounded-lg border border-slate-800 transition-all font-bold"
                                                            title="Cetak Ulang Surat Purchase Order"
                                                        >
                                                            Cetak PO
                                                        </a>
                                                    )}

                                                    {user?.role === 'owner' && (
                                                        <Link
                                                            href={`/admin/inventory/${item.id_barang}`}
                                                            className={`inline-flex items-center gap-0.5 text-[10px] font-bold transition-all duration-150 ${
                                                                isHovered ? 'text-blue-400' : 'text-slate-500 hover:text-slate-300'
                                                            }`}
                                                        >
                                                            Detail <ArrowUpRight className="w-3 h-3" />
                                                        </Link>
                                                    )}
                                                </div>
                                            </td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </AdminLayout>
    );
}
