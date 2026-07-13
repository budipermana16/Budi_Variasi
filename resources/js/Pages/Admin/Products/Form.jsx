import React from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { ArrowLeft, Save } from 'lucide-react';

const inputClass = "w-full bg-[#0a0a0f] border border-white/[0.07] text-slate-200 placeholder-slate-700 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500/30 focus:ring-1 focus:ring-blue-500/10 transition-all";
const labelClass = "block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5";

function Field({ label, error, children, hint }) {
    return (
        <div>
            <label className={labelClass}>{label}</label>
            {children}
            {hint && <p className="text-slate-700 text-[10px] mt-1">{hint}</p>}
            {error && <p className="text-red-400 text-[10px] mt-1 flex items-center gap-1"><span className="w-1 h-1 bg-red-400 rounded-full" />{error}</p>}
        </div>
    );
}

const kategoris = ['Kaca Film', 'Audio & Multimedia', 'Lampu & Elektrikal', 'Peredam Suara', 'Aksesoris Interior', 'Ban & Velg', 'Lainnya'];
const satuans   = ['pcs', 'lembar', 'unit', 'pasang', 'set', 'meter', 'roll'];

export default function ProductForm({ product, suppliers, user }) {
    const isEdit = !!product;
    const { data, setData, post, put, processing, errors } = useForm({
        nama_barang:   product?.nama_barang   ?? '',
        kategori:      product?.kategori      ?? '',
        harga_beli:    product?.harga_beli    ?? '',
        harga_jual:    product?.harga_jual    ?? '',
        stok_saat_ini: product?.stok_saat_ini ?? '',
        satuan:        product?.satuan        ?? 'pcs',
        id_supplier:   product?.id_supplier   ?? '',
        safety_stock:  product?.safety_stock  ?? 0,
    });

    const submit = (e) => {
        e.preventDefault();
        isEdit ? put(`/admin/products/${product.id_barang}`) : post('/admin/products');
    };

    return (
        <AdminLayout user={user} title={isEdit ? 'Edit Produk' : 'Tambah Produk'}>
            <Head title={`${isEdit ? 'Edit' : 'Tambah'} Produk — Budi Variasi`} />

            <div className="max-w-2xl">
                {/* Back */}
                <div className="flex items-center gap-3 mb-6">
                    <Link href="/admin/products" className="p-1.5 text-slate-600 hover:text-white hover:bg-white/[0.05] rounded-lg transition-all">
                        <ArrowLeft className="w-4 h-4" />
                    </Link>
                    <div>
                        <h2 className="text-white font-bold text-sm">{isEdit ? 'Edit Produk' : 'Produk Baru'}</h2>
                        {isEdit && <p className="text-slate-600 text-[10px] mt-0.5">{product.nama_barang}</p>}
                    </div>
                </div>

                <form onSubmit={submit}>
                    <div className="bg-[#0f0f18] border border-white/[0.05] rounded-2xl p-6 space-y-4">
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <Field label="Nama Barang" error={errors.nama_barang}>
                                <input type="text" value={data.nama_barang} onChange={e => setData('nama_barang', e.target.value)} className={inputClass} placeholder="Kaca Film 3M 20%" required />
                            </Field>

                            <Field label="Kategori" error={errors.kategori}>
                                <select value={data.kategori} onChange={e => setData('kategori', e.target.value)} className={inputClass} required>
                                    <option value="">Pilih kategori</option>
                                    {kategoris.map(k => <option key={k} value={k}>{k}</option>)}
                                </select>
                            </Field>

                            <Field label="Harga Beli (Rp)" error={errors.harga_beli}>
                                <input type="number" value={data.harga_beli} onChange={e => setData('harga_beli', e.target.value)} className={inputClass} placeholder="250000" min="0" required />
                            </Field>

                            <Field label="Harga Jual (Rp)" error={errors.harga_jual}>
                                <input type="number" value={data.harga_jual} onChange={e => setData('harga_jual', e.target.value)} className={inputClass} placeholder="350000" min="0" required />
                            </Field>

                            <Field label="Stok Saat Ini" error={errors.stok_saat_ini}>
                                <input type="number" value={data.stok_saat_ini} onChange={e => setData('stok_saat_ini', e.target.value)} className={inputClass} placeholder="10" min="0" required />
                            </Field>

                            <Field label="Satuan" error={errors.satuan}>
                                <select value={data.satuan} onChange={e => setData('satuan', e.target.value)} className={inputClass} required>
                                    {satuans.map(s => <option key={s} value={s}>{s}</option>)}
                                </select>
                            </Field>

                            <Field label="Supplier" error={errors.id_supplier}>
                                <select value={data.id_supplier} onChange={e => setData('id_supplier', e.target.value)} className={inputClass}>
                                    <option value="">Tanpa supplier</option>
                                    {suppliers.map(s => <option key={s.id_supplier} value={s.id_supplier}>{s.nama_supplier}</option>)}
                                </select>
                            </Field>

                            <Field label="Safety Stock (SS)" error={errors.safety_stock} hint="Digunakan dalam rumus: ROP = (d × L) + SS">
                                <input type="number" value={data.safety_stock} onChange={e => setData('safety_stock', e.target.value)} className={inputClass} placeholder="5" min="0" required />
                            </Field>
                        </div>

                        <div className="pt-3 border-t border-white/[0.04] flex items-center gap-3">
                            <button
                                type="submit"
                                disabled={processing}
                                className="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-500 text-white px-5 py-2.5 rounded-xl text-xs font-semibold transition-colors shadow-lg shadow-blue-500/10 disabled:opacity-50"
                            >
                                {processing ? (
                                    <span className="w-3.5 h-3.5 border border-white/30 border-t-white rounded-full animate-spin" />
                                ) : (
                                    <Save className="w-3.5 h-3.5" />
                                )}
                                {processing ? 'Menyimpan...' : 'Simpan Produk'}
                            </button>
                            <Link href="/admin/products" className="text-slate-600 hover:text-slate-400 text-xs px-4 py-2.5 rounded-xl hover:bg-white/[0.03] transition-all">
                                Batal
                            </Link>
                        </div>
                    </div>
                </form>
            </div>
        </AdminLayout>
    );
}
