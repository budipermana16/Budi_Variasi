import React, { useState } from 'react';
import { Head, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { RefreshCw, Save, X, Settings2 } from 'lucide-react';
import { cardBg, cardCls, statusBadge, inputCls, PageHeader } from '@/Lib/ui';

function EditModal({ product, onClose }) {
    const [value, setValue] = useState(product.safety_stock);
    const [saving, setSaving] = useState(false);

    const submit = (e) => {
        e.preventDefault();
        setSaving(true);
        router.put(`/admin/inventory/settings/${product.id_barang}/safety-stock`,
            { safety_stock: value },
            {
                onSuccess: () => { setSaving(false); onClose(); },
                onError:   () => setSaving(false),
                preserveScroll: true,
            }
        );
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/70 backdrop-blur-sm" onClick={onClose} />
            <div
                className="relative rounded-3xl border border-slate-850 p-6 w-full max-w-sm shadow-2xl z-10"
                style={{ backgroundColor: cardBg }}
            >
                <div className="flex items-center justify-between mb-4">
                    <div>
                        <h3 className="text-white font-bold text-sm tracking-wide">Edit Safety Stock</h3>
                        <p className="text-slate-500 text-[10px] font-medium mt-0.5">{product.nama_barang}</p>
                    </div>
                    <button onClick={onClose} className="p-1.5 text-slate-500 hover:text-white hover:bg-slate-800 rounded-xl transition-all">
                        <X className="w-4 h-4" />
                    </button>
                </div>

                {/* Formula display */}
                <div className="bg-slate-900/60 border border-slate-850 rounded-2xl p-3 mb-4">
                    <p className="text-slate-500 text-[10px] mb-1 font-bold uppercase tracking-wider">Persamaan Ambang PO</p>
                    <code className="text-xs font-mono font-bold text-slate-300">
                        ROP = (d × <span className="text-amber-400">L={product.lead_time}</span>) + <span className="text-blue-400">SS</span>
                    </code>
                </div>

                <form onSubmit={submit} className="space-y-4">
                    <div>
                        <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">
                            Safety Stock (SS) — {product.satuan}
                        </label>
                        <input
                            type="number"
                            value={value}
                            onChange={e => setValue(e.target.value)}
                            min="0"
                            className={inputCls}
                            required
                        />
                        <p className="text-slate-500 text-[10px] mt-1.5 font-medium">Lead Time pengiriman supplier: {product.lead_time} hari</p>
                    </div>
                    <div className="flex gap-3 pt-2">
                        <button
                            type="submit"
                            disabled={saving}
                            className="flex-1 flex items-center justify-center gap-2 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white py-2.5 rounded-xl text-xs font-bold disabled:opacity-50 transition-all shadow-md shadow-blue-500/10"
                        >
                            <Save className="w-4 h-4" />
                            {saving ? 'Menyimpan...' : 'Simpan Perubahan'}
                        </button>
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-4 text-slate-400 hover:text-white hover:bg-slate-800 rounded-xl text-xs font-bold transition-all"
                        >
                            Batal
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}

export default function RopSettings({ products, user }) {
    const [editing, setEditing] = useState(null);
    const [recalculating, setRecalculating] = useState(false);

    const handleRecalcAll = () => {
        if (!confirm('Apakah Anda yakin ingin menghitung ulang (recalculate) parameter ROP untuk semua produk?')) return;
        setRecalculating(true);
        router.post('/admin/inventory/settings/recalculate-all', {}, {
            onSuccess: () => setRecalculating(false),
            onError:   () => setRecalculating(false),
            preserveScroll: true,
        });
    };

    return (
        <AdminLayout user={user} title="Konfigurasi ROP">
            <Head title="Konfigurasi ROP — Budi Variasi" />

            {/* Header */}
            <PageHeader
                title="Konfigurasi Parameter ROP"
                subtitle="Atur nilai persediaan pengaman (Safety Stock) per produk untuk kalkulasi batas pemesanan ulang (ROP)"
                action={
                    <button
                        onClick={handleRecalcAll}
                        disabled={recalculating}
                        className="inline-flex items-center gap-1.5 text-white px-4 py-2.5 rounded-xl text-xs font-bold transition-all duration-300 shadow-md bg-gradient-to-r from-slate-800 to-slate-900 hover:from-slate-700 hover:to-slate-800 shadow-slate-900/20 hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-50"
                    >
                        <RefreshCw className={`w-3.5 h-3.5 ${recalculating ? 'animate-spin' : ''}`} />
                        {recalculating ? 'Memproses...' : 'Recalculate Semua ROP'}
                    </button>
                }
            />

            {/* Formula Panel */}
            <div className={`${cardCls} p-5 mb-6 bg-gradient-to-br from-slate-900/60 to-slate-950/20`} style={{ backgroundColor: cardBg }}>
                <p className="text-slate-500 text-[10px] font-bold uppercase tracking-wider mb-2">Rumus ROP & Permintaan Harian</p>
                <div className="flex flex-wrap gap-4">
                    {[
                        { formula: "ROP = (d × L) + SS", label: "d: permintaan/hari, L: lead time (hari), SS: safety stock (unit)" },
                        { formula: "d = Y' ÷ 30",        label: "Y': proyeksi penjualan bulan depan (Regresi Linear)" },
                    ].map((f, idx) => (
                        <div key={idx} className="bg-slate-950/40 border border-slate-900 rounded-xl px-4 py-2.5 flex items-center gap-3">
                            <code className="text-amber-400 font-mono text-xs font-bold whitespace-nowrap">{f.formula}</code>
                            <span className="text-slate-500 text-[10px] font-medium">{f.label}</span>
                        </div>
                    ))}
                </div>
            </div>

            {/* Table */}
            <div className={cardCls} style={{ backgroundColor: cardBg }}>
                <div className="overflow-x-auto">
                    <table className="w-full text-xs">
                        <thead>
                            <tr className="border-b border-slate-900 bg-slate-900/10 text-slate-500 text-[10px] font-bold uppercase tracking-widest">
                                <th className="px-5 py-3.5 text-left font-bold">Informasi Barang</th>
                                <th className="px-5 py-3.5 text-right font-bold">Supplier & Lead Time</th>
                                <th className="px-5 py-3.5 text-center font-bold">Safety Stock (SS)</th>
                                <th className="px-5 py-3.5 text-center font-bold">Ambang ROP</th>
                                <th className="px-5 py-3.5 text-center font-bold">Status Stok</th>
                                <th className="px-5 py-3.5 text-center font-bold" style={{ width: '80px' }}>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            {products.map(p => {
                                const badge = statusBadge[p.status_stok] ?? statusBadge['Aman'];
                                return (
                                    <tr key={p.id_barang} className="border-b border-slate-900/60 last:border-0 hover:bg-slate-900/40 transition-colors duration-200">
                                        <td className="px-5 py-4">
                                            <div className="min-w-0">
                                                <p className="text-slate-100 font-bold tracking-wide">{p.nama_barang}</p>
                                                <p className="text-slate-500 text-[10px] mt-0.5 font-medium">{p.kategori}</p>
                                            </div>
                                        </td>
                                        <td className="px-5 py-4 text-right">
                                            <p className="text-slate-300 font-semibold">{p.nama_supplier ?? '—'}</p>
                                            <p className="text-amber-400 font-mono text-[10px] mt-0.5 font-bold">L = {p.lead_time} Hari</p>
                                        </td>
                                        <td className="px-5 py-4 text-center">
                                            <span className="text-blue-400 font-extrabold text-sm font-mono">{p.safety_stock}</span>
                                            <span className="text-slate-500 text-[10px] ml-1 font-semibold">{p.satuan}</span>
                                        </td>
                                        <td className="px-5 py-4 text-center">
                                            <span className="text-slate-200 font-extrabold text-sm font-mono">{p.rop}</span>
                                            <span className="text-slate-500 text-[10px] ml-1 font-semibold">{p.satuan}</span>
                                        </td>
                                        <td className="px-5 py-4 text-center">
                                            <span className={badge}>
                                                {p.status_stok}
                                            </span>
                                        </td>
                                        <td className="px-5 py-4 text-center">
                                            <button
                                                onClick={() => setEditing(p)}
                                                className="p-2 text-slate-500 hover:text-amber-400 hover:bg-amber-500/10 rounded-xl transition-all"
                                                title="Edit Safety Stock"
                                            >
                                                <Settings2 className="w-4 h-4" />
                                            </button>
                                        </td>
                                    </tr>
                                );
                            })}
                        </tbody>
                    </table>
                </div>
            </div>

            {editing && <EditModal product={editing} onClose={() => setEditing(null)} />}
        </AdminLayout>
    );
}
