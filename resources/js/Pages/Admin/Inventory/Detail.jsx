import React from 'react';
import { Head, Link } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { ArrowLeft, TrendingUp, AlertTriangle } from 'lucide-react';

const statusConfig = {
    'Segera Pesan': { color: 'text-red-400',    bg: 'bg-red-500/10 border-red-500/20'    },
    'Waspada':      { color: 'text-yellow-400', bg: 'bg-yellow-500/10 border-yellow-500/20' },
    'Aman':         { color: 'text-emerald-400',bg: 'bg-emerald-500/10 border-emerald-500/20' },
};

export default function InventoryDetail({ product, result, user }) {
    const r = result?.regresi;
    const rop = result?.rop_detail;
    const cfg = statusConfig[result?.status_stok] ?? statusConfig['Aman'];

    return (
        <AdminLayout user={user} title={`Detail ROP — ${product.nama_barang}`}>
            <Head title={`Detail ROP: ${product.nama_barang}`} />

            <div className="flex items-center gap-3 mb-6">
                <Link href="/admin/inventory/report" className="p-2 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition-all">
                    <ArrowLeft className="w-4 h-4" />
                </Link>
                <div className="flex-1">
                    <h2 className="text-white font-extrabold text-xl">{product.nama_barang}</h2>
                    <p className="text-slate-400 text-sm">{product.kategori} · {product.supplier ?? 'Tanpa Supplier'}</p>
                </div>
                <span className={`inline-flex items-center px-3 py-1.5 rounded-full text-sm font-semibold border ${cfg.bg} ${cfg.color}`}>
                    {result?.status_stok}
                </span>
            </div>

            {result?.status === 'error' ? (
                <div className="bg-red-500/10 border border-red-500/20 rounded-2xl px-5 py-4 flex items-center gap-3">
                    <AlertTriangle className="w-5 h-5 text-red-400" />
                    <p className="text-red-400">{result.pesan}</p>
                </div>
            ) : (
                <div className="space-y-6">
                    {/* Kartu Ringkasan */}
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                        {[
                            { label: 'Prediksi Y\'', value: `${r?.y_prediksi?.toFixed(2)} unit/bln`, sub: `Persamaan: ${r?.persamaan}` },
                            { label: 'd (per hari)',  value: rop?.d?.toFixed(4),     sub: `= ${r?.y_prediksi?.toFixed(2)} / 30` },
                            { label: 'Lead Time (L)', value: `${rop?.lead_time} hari`, sub: 'Dari data supplier' },
                            { label: 'Safety Stock', value: `${rop?.safety_stock} ${product.satuan}`, sub: 'Diinput manual' },
                        ].map((c, i) => (
                            <div key={i} className="bg-slate-900 border border-white/5 rounded-2xl p-4">
                                <p className="text-slate-500 text-xs mb-1">{c.label}</p>
                                <p className="text-white font-extrabold text-lg leading-tight">{c.value}</p>
                                <p className="text-slate-600 text-[10px] mt-1 font-mono">{c.sub}</p>
                            </div>
                        ))}
                    </div>

                    {/* ROP Result */}
                    <div className="bg-gradient-to-r from-cyan-500/10 to-blue-500/10 border border-cyan-500/20 rounded-2xl p-5 flex flex-col sm:flex-row items-center gap-4">
                        <TrendingUp className="w-10 h-10 text-cyan-400 flex-shrink-0" />
                        <div className="text-center sm:text-left">
                            <p className="text-slate-400 text-sm">Hasil Perhitungan ROP</p>
                            <p className="text-white font-extrabold text-3xl mt-1">
                                ROP = ({rop?.d?.toFixed(4)} × {rop?.lead_time}) + {rop?.safety_stock} = <span className="text-cyan-400">{rop?.rop} {product.satuan}</span>
                            </p>
                            <p className="text-slate-400 text-sm mt-1">
                                Stok saat ini: <span className={`font-bold ${result.stok_saat_ini <= rop?.rop ? 'text-red-400' : 'text-emerald-400'}`}>{result.stok_saat_ini} {product.satuan}</span>
                                {result.stok_saat_ini <= rop?.rop && <span className="text-red-400 ml-2">⚠ Stok di bawah ROP! Segera pesan.</span>}
                            </p>
                        </div>
                    </div>

                    {/* Tabel Data Historis Regresi */}
                    <div className="bg-slate-900 border border-white/5 rounded-2xl overflow-hidden">
                        <div className="px-5 py-4 border-b border-white/5">
                            <h3 className="text-white font-bold">Tabel Data Historis Regresi Linear</h3>
                            <p className="text-slate-400 text-xs mt-0.5">n = {r?.n} bulan · a = {r?.a} · b = {r?.b}</p>
                        </div>
                        <div className="overflow-x-auto">
                            <table className="w-full text-sm">
                                <thead>
                                    <tr className="border-b border-white/5 text-slate-500 text-xs uppercase tracking-wide">
                                        <th className="px-5 py-3 text-center font-medium">Periode (X)</th>
                                        <th className="px-5 py-3 text-left font-medium">Bulan/Tahun</th>
                                        <th className="px-5 py-3 text-right font-medium">Y (Terjual)</th>
                                        <th className="px-5 py-3 text-right font-medium">X²</th>
                                        <th className="px-5 py-3 text-right font-medium">XY</th>
                                        <th className="px-5 py-3 text-right font-medium text-cyan-400/70">Y' (Prediksi)</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-white/5">
                                    {r?.data_historis?.map((row) => {
                                        const yHat = r.a + r.b * row.periode;
                                        return (
                                            <tr key={row.periode} className="hover:bg-slate-800/40">
                                                <td className="px-5 py-2.5 text-center text-slate-400 font-mono">{row.periode}</td>
                                                <td className="px-5 py-2.5 text-slate-300">{row.label}</td>
                                                <td className="px-5 py-2.5 text-right text-white font-semibold">{row.total_terjual}</td>
                                                <td className="px-5 py-2.5 text-right text-slate-400 font-mono text-xs">{row.periode * row.periode}</td>
                                                <td className="px-5 py-2.5 text-right text-slate-400 font-mono text-xs">{row.periode * row.total_terjual}</td>
                                                <td className="px-5 py-2.5 text-right text-cyan-400 font-mono text-xs">{yHat.toFixed(2)}</td>
                                            </tr>
                                        );
                                    })}
                                    {/* Baris prediksi */}
                                    <tr className="bg-cyan-500/5 border-t-2 border-cyan-500/20">
                                        <td className="px-5 py-3 text-center text-cyan-400 font-mono font-bold">{r?.x_prediksi}</td>
                                        <td className="px-5 py-3 text-cyan-400 font-semibold">Bulan Depan (Prediksi)</td>
                                        <td className="px-5 py-3 text-right text-slate-500">—</td>
                                        <td className="px-5 py-3 text-right text-slate-500 text-xs font-mono">{r?.x_prediksi * r?.x_prediksi}</td>
                                        <td className="px-5 py-3 text-right text-slate-500">—</td>
                                        <td className="px-5 py-3 text-right text-cyan-400 font-extrabold">{r?.y_prediksi?.toFixed(2)}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            )}
        </AdminLayout>
    );
}
