import React, { useState, useMemo } from 'react';
import { Head, Link, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, Pencil, Trash2, Search } from 'lucide-react';
import { cardBg, cardCls, inputCls, statusBadge, PageHeader, BtnPrimary } from '@/Lib/ui';

export default function ProductIndex({ products, user }) {
    const [search, setSearch] = useState('');
    const [filterStatus, setFilterStatus] = useState('all');
    const [hoveredRow, setHoveredRow] = useState(null);

    const filtered = useMemo(() => products.filter(p => {
        const matchSearch = p.nama_barang.toLowerCase().includes(search.toLowerCase()) ||
                            p.kategori.toLowerCase().includes(search.toLowerCase());
        const matchStatus = filterStatus === 'all' || p.status_stok === filterStatus;
        return matchSearch && matchStatus;
    }), [products, search, filterStatus]);

    const formatRp = (n) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(n);

    const handleDelete = (id, nama) => {
        if (confirm(`Apakah Anda yakin ingin menghapus produk "${nama}"?`)) {
            router.delete(`/admin/products/${id}`);
        }
    };

    const counts = {
        all:          products.length,
        'Segera Pesan': products.filter(p => p.status_stok === 'Segera Pesan').length,
        'Waspada':      products.filter(p => p.status_stok === 'Waspada').length,
        'Aman':         products.filter(p => p.status_stok === 'Aman').length,
    };

    return (
        <AdminLayout user={user} title="Daftar Produk">
            <Head title="Manajemen Produk — Budi Variasi" />

            {/* Page Header */}
            <PageHeader
                title="Manajemen Data Produk"
                subtitle="Kelola data barang, kategori, harga, dan monitor status reorder point (ROP)"
                action={
                    <BtnPrimary href="/admin/products/create" color="blue">
                        <Plus className="w-4 h-4" /> Tambah Produk Baru
                    </BtnPrimary>
                }
            />

            {/* Controls & Filter */}
            <div className="flex flex-col md:flex-row gap-4 mb-6">
                <div className="relative flex-1">
                    <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-600" />
                    <input
                        type="text"
                        placeholder="Cari nama barang atau kategori..."
                        value={search}
                        onChange={e => setSearch(e.target.value)}
                        className={inputCls}
                    />
                </div>

                <div className="flex gap-2 overflow-x-auto pb-1 md:pb-0">
                    {[
                        { key: 'all',          label: 'Semua Produk' },
                        { key: 'Segera Pesan', label: 'Kritis' },
                        { key: 'Waspada',      label: 'Waspada' },
                        { key: 'Aman',         label: 'Aman' },
                    ].map(f => (
                        <button
                            key={f.key}
                            onClick={() => setFilterStatus(f.key)}
                            className={`px-4 py-2.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap ${
                                filterStatus === f.key
                                    ? 'bg-blue-600 text-white shadow-md shadow-blue-500/10'
                                    : 'bg-slate-900 border border-slate-800 text-slate-400 hover:text-slate-200 hover:bg-slate-800'
                            }`}
                        >
                            {f.label}
                            <span className="ml-1.5 opacity-60 font-semibold">({counts[f.key] ?? 0})</span>
                        </button>
                    ))}
                </div>
            </div>

            {/* Table Container */}
            <div className={cardCls} style={{ backgroundColor: cardBg }}>
                <div className="overflow-x-auto">
                    <table className="w-full text-xs">
                        <thead>
                            <tr className="border-b border-slate-900 bg-slate-900/10 text-slate-500 text-[10px] font-bold uppercase tracking-widest">
                                <th className="px-5 py-3.5 text-left font-bold">Informasi Barang</th>
                                <th className="px-5 py-3.5 text-left font-bold">Kategori</th>
                                <th className="px-5 py-3.5 text-right font-bold">Harga Jual</th>
                                <th className="px-5 py-3.5 text-right font-bold">Stok Saat Ini</th>
                                <th className="px-5 py-3.5 text-right font-bold">SS / ROP</th>
                                <th className="px-5 py-3.5 text-center font-bold">Status Stok</th>
                                <th className="px-5 py-3.5 text-center font-bold" style={{ width: '100px' }}>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filtered.length === 0 ? (
                                <tr>
                                    <td colSpan={7} className="px-5 py-16 text-center text-slate-500 font-medium">
                                        Tidak ditemukan produk yang cocok dengan pencarian.
                                    </td>
                                </tr>
                            ) : filtered.map((p, idx) => {
                                const s = statusBadge[p.status_stok] ?? statusBadge['Aman'];
                                const isHovered = hoveredRow === idx;
                                return (
                                    <tr
                                        key={p.id_barang}
                                        onMouseEnter={() => setHoveredRow(idx)}
                                        onMouseLeave={() => setHoveredRow(null)}
                                        className={`border-b border-slate-900/60 last:border-0 transition-colors duration-200 ${isHovered ? 'bg-slate-900/40' : ''}`}
                                    >
                                        <td className="px-5 py-4">
                                            <div className="min-w-0">
                                                <p className="text-slate-100 font-bold tracking-wide">{p.nama_barang}</p>
                                                <p className="text-slate-500 text-[10px] mt-0.5 font-medium">{p.supplier ?? '—'}</p>
                                            </div>
                                        </td>
                                        <td className="px-5 py-4 text-slate-400 font-semibold">
                                            {p.kategori}
                                        </td>
                                        <td className="px-5 py-4 text-right font-mono font-bold text-emerald-400">
                                            {formatRp(p.harga_jual)}
                                        </td>
                                        <td className="px-5 py-4 text-right">
                                            <span className={`font-bold ${p.stok_saat_ini <= p.rop ? 'text-rose-400' : 'text-slate-100'}`}>
                                                {p.stok_saat_ini}
                                            </span>
                                            <span className="text-slate-500 text-[10px] ml-1 font-semibold">{p.satuan}</span>
                                        </td>
                                        <td className="px-5 py-4 text-right font-mono text-slate-400 font-bold">
                                            {p.safety_stock} / {p.rop}
                                        </td>
                                        <td className="px-5 py-4 text-center">
                                            <span className={s}>
                                                {p.status_stok}
                                            </span>
                                        </td>
                                        <td className="px-5 py-4">
                                            <div className="flex items-center justify-center gap-1.5">
                                                <Link
                                                    href={`/admin/products/${p.id_barang}/edit`}
                                                    className="p-2 text-slate-500 hover:text-blue-400 hover:bg-blue-500/10 rounded-xl transition-all"
                                                    title="Edit Barang"
                                                >
                                                    <Pencil className="w-4 h-4" />
                                                </Link>
                                                <button
                                                    onClick={() => handleDelete(p.id_barang, p.nama_barang)}
                                                    className="p-2 text-slate-500 hover:text-rose-400 hover:bg-rose-500/10 rounded-xl transition-all"
                                                    title="Hapus Barang"
                                                >
                                                    <Trash2 className="w-4 h-4" />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                );
                            })}
                        </tbody>
                    </table>
                </div>
            </div>
        </AdminLayout>
    );
}
