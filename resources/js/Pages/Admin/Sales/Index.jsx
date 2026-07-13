import React from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, ShoppingCart, Trash2 } from 'lucide-react';

export default function SaleIndex({ sales, user }) {
    const formatRupiah = (n) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(n);
    const formatTanggal = (d) => {
        if (!d) return '—';
        const date = new Date(d);
        return date.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
    };

    const handleDelete = (id) => {
        if (confirm('Yakin ingin membatalkan transaksi ini? Stok fisik produk akan dikembalikan.')) {
            router.delete(`/admin/sales/${id}`, { preserveScroll: true });
        }
    };

    return (
        <AdminLayout user={user} title="Riwayat Penjualan">
            <Head title="Penjualan — Budi Variasi Admin" />

            <div className="flex items-center justify-between mb-6">
                <div>
                    <h2 className="text-white font-semibold text-lg">Riwayat Penjualan</h2>
                    <p className="text-slate-400 text-sm mt-0.5">Data penjualan sebagai input regresi linear</p>
                </div>
                <Link href="/admin/sales/create"
                    className="inline-flex items-center gap-2 bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors">
                    <Plus className="w-4 h-4" /> Catat Penjualan
                </Link>
            </div>

            <div className="bg-slate-800 border border-slate-700 rounded-xl overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-sm">
                        <thead>
                            <tr className="border-b border-slate-700 text-slate-400 text-xs uppercase tracking-wider">
                                <th className="px-5 py-3 text-left font-medium">#</th>
                                <th className="px-5 py-3 text-left font-medium">Nama Barang</th>
                                <th className="px-5 py-3 text-left font-medium">Tanggal</th>
                                <th className="px-5 py-3 text-right font-medium">Jumlah</th>
                                <th className="px-5 py-3 text-right font-medium">Total</th>
                                <th className="px-5 py-3 text-center font-medium">Aksi</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-slate-700">
                            {sales.data.length === 0 ? (
                                <tr>
                                    <td colSpan={6} className="px-5 py-16 text-center">
                                        <ShoppingCart className="w-10 h-10 text-slate-600 mx-auto mb-3" />
                                        <p className="text-slate-500 text-sm">Belum ada data penjualan.</p>
                                    </td>
                                </tr>
                            ) : sales.data.map((s, i) => (
                                <tr key={s.id_penjualan} className="hover:bg-slate-700/40 transition-colors">
                                    <td className="px-5 py-3.5 text-slate-500 text-sm">{i + 1}</td>
                                    <td className="px-5 py-3.5 text-slate-100 font-medium">{s.nama_barang}</td>
                                    <td className="px-5 py-3.5 text-slate-300">{s.tanggal_keluar}</td>
                                    <td className="px-5 py-3.5 text-right">
                                        <span className="text-slate-100 font-semibold">{s.jumlah_terjual}</span>
                                        <span className="text-slate-500 text-xs ml-1">{s.satuan}</span>
                                    </td>
                                    <td className="px-5 py-3.5 text-right text-emerald-400 font-semibold">{formatRupiah(s.total_harga)}</td>
                                    <td className="px-5 py-3.5 text-center">
                                        <button
                                            onClick={() => handleDelete(s.id_penjualan)}
                                            className="p-2 text-slate-400 hover:text-red-400 hover:bg-red-950 rounded-lg transition-colors"
                                            title="Batalkan & Kembalikan Stok"
                                        >
                                            <Trash2 className="w-4 h-4" />
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                {sales.last_page > 1 && (
                    <div className="px-5 py-4 border-t border-slate-700 flex items-center justify-between text-sm">
                        <p className="text-slate-400">Hal {sales.current_page} dari {sales.last_page}</p>
                        <div className="flex gap-2">
                            {sales.links.map((link, i) => (
                                <Link
                                    key={i}
                                    href={link.url ?? '#'}
                                    dangerouslySetInnerHTML={{ __html: link.label }}
                                    className={`px-3 py-1.5 rounded-lg text-xs transition-colors ${
                                        link.active
                                            ? 'bg-blue-600 text-white'
                                            : 'text-slate-400 hover:text-white hover:bg-slate-700'
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
