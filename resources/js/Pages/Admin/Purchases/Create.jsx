import React from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Save, ArrowLeft, Plus, Trash2 } from 'lucide-react';

const inputClass = "w-full bg-slate-800 border border-white/10 text-white placeholder-slate-500 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-cyan-500/50 focus:ring-2 focus:ring-cyan-500/20 transition-all";

export default function PurchaseCreate({ products, suppliers, user }) {
    const { data, setData, post, processing, errors } = useForm({
        tanggal_masuk: new Date().toISOString().split('T')[0],
        id_supplier:   '',
        items: [
            { id_barang: '', jumlah_masuk: '' }
        ]
    });

    const handleItemChange = (index, field, value) => {
        const newItems = [...data.items];
        newItems[index] = { ...newItems[index], [field]: value };
        setData('items', newItems);
    };

    const addItem = () => {
        setData('items', [...data.items, { id_barang: '', jumlah_masuk: '' }]);
    };

    const removeItem = (index) => {
        if (data.items.length > 1) {
            const newItems = data.items.filter((_, idx) => idx !== index);
            setData('items', newItems);
        }
    };

    const submit = (e) => {
        e.preventDefault();
        post('/admin/purchases');
    };

    return (
        <AdminLayout user={user} title="Catat Barang Masuk">
            <Head title="Barang Masuk — Budi Variasi Admin" />

            <div className="max-w-4xl">
                <div className="flex items-center gap-3 mb-6">
                    <Link href="/admin/purchases" className="p-2 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition-all">
                        <ArrowLeft className="w-4 h-4" />
                    </Link>
                    <div>
                        <h2 className="text-white font-extrabold text-xl">Catat Barang Masuk</h2>
                        <p className="text-slate-400 text-sm">Stok akan bertambah otomatis setelah disimpan</p>
                    </div>
                </div>

                <form onSubmit={submit} className="bg-slate-900 border border-white/5 rounded-2xl p-6 space-y-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {/* Supplier */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-1.5">Supplier</label>
                            <select value={data.id_supplier} onChange={e => setData('id_supplier', e.target.value)} className={inputClass}>
                                <option value="">-- Tanpa Supplier --</option>
                                {suppliers.map(s => (
                                    <option key={s.id_supplier} value={s.id_supplier}>{s.nama_supplier}</option>
                                ))}
                            </select>
                            {errors.id_supplier && <p className="text-red-400 text-xs mt-1">{errors.id_supplier}</p>}
                        </div>

                        {/* Tanggal Masuk */}
                        <div>
                            <label className="block text-sm font-medium text-slate-300 mb-1.5">Tanggal Masuk</label>
                            <input type="date" value={data.tanggal_masuk} onChange={e => setData('tanggal_masuk', e.target.value)} className={inputClass} required />
                            {errors.tanggal_masuk && <p className="text-red-400 text-xs mt-1">{errors.tanggal_masuk}</p>}
                        </div>
                    </div>

                    {/* List of Items */}
                    <div className="space-y-4">
                        <div className="flex justify-between items-center border-b border-white/5 pb-2">
                            <h3 className="text-white font-bold text-md">Daftar Barang Masuk</h3>
                            <button
                                type="button"
                                onClick={addItem}
                                className="inline-flex items-center gap-1.5 text-xs text-blue-400 hover:text-blue-300 font-semibold px-3 py-1.5 rounded-lg hover:bg-blue-500/10 transition-all border border-blue-500/20"
                            >
                                <Plus className="w-3.5 h-3.5" />
                                Tambah Barang
                            </button>
                        </div>

                        <div className="space-y-3">
                            {data.items.map((item, index) => {
                                const selectedProd = products.find(p => p.id_barang == item.id_barang);
                                const currentStock = selectedProd ? selectedProd.stok_saat_ini : 0;
                                const futureStock = currentStock + (parseInt(item.jumlah_masuk) || 0);

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
                                                value={item.jumlah_masuk}
                                                onChange={e => handleItemChange(index, 'jumlah_masuk', e.target.value)}
                                                className={`${inputClass} ${errors[`items.${index}.jumlah_masuk`] ? 'border-red-500/50' : ''}`}
                                                placeholder="10"
                                                min="1"
                                                required
                                            />
                                            {errors[`items.${index}.jumlah_masuk`] && (
                                                <p className="text-red-400 text-xs mt-1">{errors[`items.${index}.jumlah_masuk`]}</p>
                                            )}
                                        </div>

                                        {/* Estimasi / Stok Info */}
                                        <div className="w-full md:w-48 text-left md:text-right pt-2 md:pt-4">
                                            {selectedProd ? (
                                                <div className="text-xs text-slate-400">
                                                    <p>Stok lama: <span className="text-slate-300 font-semibold">{currentStock} {selectedProd.satuan}</span></p>
                                                    <p className="text-emerald-400">Stok baru: <span className="font-bold">{futureStock} {selectedProd.satuan}</span></p>
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

                    {/* Actions */}
                    <div className="flex items-center gap-3 pt-4 border-t border-white/5">
                        <button type="submit" disabled={processing} className="inline-flex items-center gap-2 bg-gradient-to-r from-blue-600 to-cyan-500 text-white px-6 py-2.5 rounded-xl text-sm font-semibold shadow-lg shadow-blue-500/20 transition-all disabled:opacity-60">
                            <Save className="w-4 h-4" />
                            {processing ? 'Menyimpan...' : 'Simpan Barang Masuk'}
                        </button>
                        <Link href="/admin/purchases" className="text-slate-400 hover:text-white text-sm px-4 py-2.5 rounded-xl hover:bg-slate-800 transition-all">
                            Batal
                        </Link>
                    </div>
                </form>
            </div>
        </AdminLayout>
    );
}
