import React from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, PackagePlus, Trash2 } from 'lucide-react';

export default function PurchaseIndex({ purchases, user }) {
    const formatRupiah = (n) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(n);
    const formatTanggal = (d) => {
        if (!d) return '—';
        const date = new Date(d);
        return date.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
    };

    const handleDelete = (id) => {
        if (confirm('Hapus data ini? Stok produk akan dikembalikan secara otomatis.')) {
            router.delete(`/admin/purchases/${id}`, { preserveScroll: true });
        }
    };

    return (
        <AdminLayout user={user} title="Riwayat Barang Masuk">
            <Head title="Barang Masuk — Budi Variasi Admin" />

            <div className="flex items-center justify-between mb-6">
                <div>
                    <h2 className="text-white font-bold text-sm">Riwayat Barang Masuk</h2>
                    <p className="text-slate-600 text-xs mt-0.5">Log pasokan dari supplier — stok akan dikembalikan jika dihapus</p>
                </div>
                <Link
                    href="/admin/purchases/create"
                    className="inline-flex items-center gap-1.5 bg-orange-600 hover:bg-orange-500 text-white px-3.5 py-2 rounded-xl text-xs font-semibold transition-colors shadow-lg shadow-orange-500/10 flex-shrink-0"
                >
                    <Plus className="w-3.5 h-3.5" />
                    Catat Barang Masuk
                </Link>
            </div>

            <div className="bg-[#0f0f18] border border-white/[0.05] rounded-2xl overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead>
                            <tr className="border-b border-white/[0.04]">
                                {['#', 'Nama Barang', 'Supplier', 'Tanggal Masuk', 'Jumlah', 'Aksi'].map((h, i) => (
                                    <th key={i} className={`px-4 py-3 text-[10px] font-semibold text-slate-600 uppercase tracking-widest ${i === 0 || i === 1 || i === 2 ? 'text-left' : 'text-right'} ${i === 5 ? 'text-center' : ''}`}>
                                        {h}
                                    </th>
                                ))}
                            </tr>
                        </thead>
                        <tbody>
                            {purchases.data.length === 0 ? (
                                <tr>
                                    <td colSpan={6} className="px-4 py-12 text-center">
                                        <PackagePlus className="w-10 h-10 text-slate-700 mx-auto mb-3" />
                                        <p className="text-slate-500 text-xs">Belum ada data barang masuk.</p>
                                    </td>
                                </tr>
                            ) : purchases.data.map((p, i) => (
                                <tr key={p.id_pembelian} className="border-b border-white/[0.03] last:border-0 hover:bg-white/[0.015] transition-colors">
                                    <td className="px-4 py-3.5 text-slate-600 text-xs">{i + 1}</td>
                                    <td className="px-4 py-3.5">
                                        <p className="text-slate-200 text-xs font-semibold">{p.product?.nama_barang ?? '—'}</p>
                                    </td>
                                    <td className="px-4 py-3.5">
                                        <span className="text-slate-400 text-xs">{p.supplier?.nama_supplier ?? <span className="text-slate-700">Tanpa supplier</span>}</span>
                                    </td>
                                    <td className="px-4 py-3.5 text-right">
                                        <span className="text-slate-400 text-xs">{formatTanggal(p.tanggal_masuk)}</span>
                                    </td>
                                    <td className="px-4 py-3.5 text-right">
                                        <span className="text-orange-400 font-bold text-sm">+{p.jumlah_masuk}</span>
                                        <span className="text-slate-600 text-[10px] ml-1">{p.product?.satuan}</span>
                                    </td>
                                    <td className="px-4 py-3.5 text-center">
                                        <button
                                            onClick={() => handleDelete(p.id_pembelian)}
                                            className="p-1.5 text-slate-500 hover:text-red-400 hover:bg-red-500/10 rounded-lg transition-all"
                                            title="Hapus & Kembalikan Stok"
                                        >
                                            <Trash2 className="w-3.5 h-3.5" />
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                {purchases.last_page > 1 && (
                    <div className="px-4 py-3 border-t border-white/[0.04] flex items-center justify-between text-xs">
                        <p className="text-slate-600">Hal {purchases.current_page} dari {purchases.last_page}</p>
                        <div className="flex gap-1.5">
                            {purchases.links.map((link, i) => (
                                <Link
                                    key={i}
                                    href={link.url ?? '#'}
                                    dangerouslySetInnerHTML={{ __html: link.label }}
                                    className={`px-2.5 py-1 rounded-lg text-[10px] transition-all ${
                                        link.active
                                            ? 'bg-orange-500/15 text-orange-400 border border-orange-500/25'
                                            : 'text-slate-500 hover:text-white hover:bg-slate-800'
                                    }`}
                                />
                            ))}
                        </div>
                    </div>
                )}
            </div>
        </AdminLayout>
    );
}
