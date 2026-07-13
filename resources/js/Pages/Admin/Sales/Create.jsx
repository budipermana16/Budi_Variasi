import React from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Save, ArrowLeft, AlertCircle, Plus, Trash2 } from 'lucide-react';

const inputClass = "w-full bg-slate-800 border border-white/10 text-white placeholder-slate-500 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-cyan-500/50 focus:ring-2 focus:ring-cyan-500/20 transition-all";

export default function SaleCreate({ products, user }) {
    const { data, setData, post, processing, errors } = useForm({
        tanggal_keluar: new Date().toISOString().split('T')[0],
        items: [
            { id_barang: '', jumlah_terjual: '' }
        ]
    });

    const formatRupiah = (n) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(n);

    const handleItemChange = (index, field, value) => {
        const newItems = [...data.items];
        newItems[index] = { ...newItems[index], [field]: value };
        setData('items', newItems);
    };

    const addItem = () => {
        setData('items', [...data.items, { id_barang: '', jumlah_terjual: '' }]);
    };

    const removeItem = (index) => {
        if (data.items.length > 1) {
            const newItems = data.items.filter((_, idx) => idx !== index);
            setData('items', newItems);
        }
    };

    // Calculate total price of all items
    const totalHargaPenjualan = data.items.reduce((sum, item) => {
        const prod = products.find(p => p.id_barang == item.id_barang);
        return sum + (prod ? prod.harga_jual * (parseInt(item.jumlah_terjual) || 0) : 0);
    }, 0);

    // Check if stock is sufficient for all items
    const isStokCukupGlobal = data.items.every(item => {
        if (!item.id_barang) return true;
        const prod = products.find(p => p.id_barang == item.id_barang);
        if (!prod) return true;
        
        // Sum up quantities of same product (in case of duplicates)
        const totalRequested = data.items
            .filter(it => it.id_barang == item.id_barang)
            .reduce((sum, it) => sum + (parseInt(it.jumlah_terjual) || 0), 0);

        return prod.stok_saat_ini >= totalRequested;
    });

    const submit = (e) => {
        e.preventDefault();
        post('/admin/sales');
    };

    return (
        <AdminLayout user={user} title="Catat Penjualan">
            <Head title="Catat Penjualan — Budi Variasi Admin" />

            <div className="max-w-4xl">
                <div className="flex items-center gap-3 mb-6">
                    <Link href="/admin/sales" className="p-2 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition-all">
                        <ArrowLeft className="w-4 h-4" />
                    </Link>
                    <div>
                        <h2 className="text-white font-extrabold text-xl">Catat Penjualan</h2>
                        <p className="text-slate-400 text-sm">Stok akan berkurang otomatis setelah disimpan</p>
                    </div>
                </div>

                <form onSubmit={submit} className="bg-slate-900 border border-white/5 rounded-2xl p-6 space-y-6">
                    {/* Tanggal */}
                    <div className="max-w-md">
                        <label className="block text-sm font-medium text-slate-300 mb-1.5">Tanggal Penjualan</label>
                        <input
                            type="date"
                            value={data.tanggal_keluar}
                            onChange={e => setData('tanggal_keluar', e.target.value)}
                            className={inputClass}
                            required
                        />
                        {errors.tanggal_keluar && <p className="text-red-400 text-xs mt-1">{errors.tanggal_keluar}</p>}
                    </div>

                    {/* List of Items */}
                    <div className="space-y-4">
                        <div className="flex justify-between items-center border-b border-white/5 pb-2">
                            <h3 className="text-white font-bold text-md">Daftar Barang Belanjaan</h3>
                            <button
                                type="button"
                                onClick={addItem}
                                className="inline-flex items-center gap-1.5 text-xs text-cyan-400 hover:text-cyan-300 font-semibold px-3 py-1.5 rounded-lg hover:bg-cyan-500/10 transition-all border border-cyan-500/20"
                            >
                                <Plus className="w-3.5 h-3.5" />
                                Tambah Barang
                            </button>
                        </div>

                        <div className="space-y-3">
                            {data.items.map((item, index) => {
                                const selectedProd = products.find(p => p.id_barang == item.id_barang);
                                const subtotal = selectedProd ? selectedProd.harga_jual * (parseInt(item.jumlah_terjual) || 0) : 0;
                                
                                // Sum up quantities of same product to check stock
                                const totalRequested = item.id_barang ? data.items
                                    .filter(it => it.id_barang == item.id_barang)
                                    .reduce((sum, it) => sum + (parseInt(it.jumlah_terjual) || 0), 0) : 0;

                                const isQtyInvalid = selectedProd && selectedProd.stok_saat_ini < totalRequested;

                                return (
                                    <div key={index} className="bg-slate-800/40 border border-white/5 rounded-xl p-4 space-y-4 md:space-y-0 md:flex md:items-center md:gap-4 transition-all hover:border-white/10">
                                        {/* Pilih Produk */}
                                        <div className="flex-1">
                                            <label className="block text-xs font-medium text-slate-400 mb-1">Barang #{index + 1}</label>
                                            <select
                                                value={item.id_barang}
                                                onChange={e => handleItemChange(index, 'id_barang', e.target.value)}
                                                className={inputClass}
                                                required
                                            >
                                                <option value="">-- Pilih Barang --</option>
                                                {products.map(p => {
                                                    const isAlreadySelected = data.items.some((it, idx) => it.id_barang == p.id_barang && idx !== index);
                                                    return (
                                                        <option key={p.id_barang} value={p.id_barang} disabled={isAlreadySelected}>
                                                            {p.nama_barang} (Stok: {p.stok_saat_ini} {p.satuan}) {isAlreadySelected ? '(Terpilih)' : ''}
                                                        </option>
                                                    );
                                                })}
                                            </select>
                                            {errors[`items.${index}.id_barang`] && (
                                                <p className="text-red-400 text-xs mt-1">{errors[`items.${index}.id_barang`]}</p>
                                            )}
                                        </div>

                                        {/* Jumlah */}
                                        <div className="w-full md:w-32">
                                            <label className="block text-xs font-medium text-slate-400 mb-1">Jumlah</label>
                                            <input
                                                type="number"
                                                value={item.jumlah_terjual}
                                                onChange={e => handleItemChange(index, 'jumlah_terjual', e.target.value)}
                                                className={`${inputClass} ${isQtyInvalid || errors[`items.${index}.jumlah_terjual`] ? 'border-red-500/50' : ''}`}
                                                placeholder="1"
                                                min="1"
                                                required
                                            />
                                            {errors[`items.${index}.jumlah_terjual`] && (
                                                <p className="text-red-400 text-xs mt-1">{errors[`items.${index}.jumlah_terjual`]}</p>
                                            )}
                                        </div>

                                        {/* Estimasi / Harga */}
                                        <div className="w-full md:w-48 text-left md:text-right pt-2 md:pt-4">
                                            {selectedProd ? (
                                                <div>
                                                    <p className="text-[11px] text-slate-500">@ {formatRupiah(selectedProd.harga_jual)}</p>
                                                    <p className="text-sm font-bold text-cyan-400">{formatRupiah(subtotal)}</p>
                                                    {isQtyInvalid && (
                                                        <div className="flex items-center gap-1 text-red-400 text-[10px] mt-0.5 justify-start md:justify-end">
                                                            <AlertCircle className="w-3 h-3 flex-shrink-0" />
                                                            <span>Stok kurang (Sisa: {selectedProd.stok_saat_ini})</span>
                                                        </div>
                                                    )}
                                                </div>
                                            ) : (
                                                <p className="text-xs text-slate-500 italic">Pilih barang...</p>
                                            )}
                                        </div>

                                        {/* Action */}
                                        <div className="pt-2 md:pt-4 flex justify-end">
                                            <button
                                                type="button"
                                                onClick={() => removeItem(index)}
                                                disabled={data.items.length === 1}
                                                className="p-2 text-slate-400 hover:text-red-400 hover:bg-red-500/10 rounded-lg transition-all disabled:opacity-30 disabled:hover:bg-transparent"
                                                title="Hapus Barang"
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    </div>

                    {/* Summary Card */}
                    <div className="bg-slate-800/60 border border-white/5 rounded-xl p-4 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                        <div>
                            <p className="text-slate-400 text-xs">Total Transaksi</p>
                            <p className="text-2xl font-black text-emerald-400">{formatRupiah(totalHargaPenjualan)}</p>
                        </div>
                        {!isStokCukupGlobal && (
                            <div className="flex items-center gap-2 bg-red-500/10 border border-red-500/20 text-red-400 text-xs rounded-xl px-4 py-2">
                                <AlertCircle className="w-4 h-4 flex-shrink-0" />
                                <span>Salah satu barang memiliki jumlah melebihi stok yang tersedia.</span>
                            </div>
                        )}
                    </div>

                    {/* Actions */}
                    <div className="flex items-center gap-3 pt-4 border-t border-white/5">
                        <button
                            type="submit"
                            disabled={processing || !isStokCukupGlobal}
                            className="inline-flex items-center gap-2 bg-gradient-to-r from-emerald-600 to-green-500 text-white px-6 py-2.5 rounded-xl text-sm font-semibold shadow-lg shadow-emerald-500/20 transition-all disabled:opacity-50"
                        >
                            <Save className="w-4 h-4" />
                            {processing ? 'Menyimpan...' : 'Simpan Penjualan'}
                        </button>
                        <Link href="/admin/sales" className="text-slate-400 hover:text-white text-sm px-4 py-2.5 rounded-xl hover:bg-slate-800 transition-all">
                            Batal
                        </Link>
                    </div>
                </form>
            </div>
        </AdminLayout>
    );
}
