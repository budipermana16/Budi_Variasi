import React, { useState } from 'react';
import { Head, useForm, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, Pencil, Trash2, X, Save } from 'lucide-react';

const inputClass = "w-full bg-slate-800 border border-white/10 text-white placeholder-slate-500 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-cyan-500/50 focus:ring-2 focus:ring-cyan-500/20 transition-all";

function SupplierModal({ onClose, editData }) {
    const isEdit = !!editData;
    const { data, setData, post, put, processing, errors } = useForm({
        nama_supplier:       editData?.nama_supplier       ?? '',
        alamat:              editData?.alamat              ?? '',
        kontak_person:       editData?.kontak_person       ?? '',
        lead_time_rata_rata: editData?.lead_time_rata_rata ?? 7,
    });

    const submit = (e) => {
        e.preventDefault();
        if (isEdit) {
            put(`/admin/suppliers/${editData.id_supplier}`, { onSuccess: onClose });
        } else {
            post('/admin/suppliers', { onSuccess: onClose });
        }
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose} />
            <div className="relative bg-slate-900 border border-white/10 rounded-2xl p-6 w-full max-w-md shadow-2xl">
                <div className="flex items-center justify-between mb-5">
                    <h3 className="text-white font-bold">{isEdit ? 'Edit Supplier' : 'Tambah Supplier'}</h3>
                    <button onClick={onClose} className="text-slate-400 hover:text-white"><X className="w-5 h-5" /></button>
                </div>
                <form onSubmit={submit} className="space-y-4">
                    <div>
                        <label className="text-xs text-slate-400 font-medium mb-1 block">Nama Supplier</label>
                        <input type="text" value={data.nama_supplier} onChange={e => setData('nama_supplier', e.target.value)} className={inputClass} placeholder="PT. Nama Supplier" required />
                        {errors.nama_supplier && <p className="text-red-400 text-xs mt-1">{errors.nama_supplier}</p>}
                    </div>
                    <div>
                        <label className="text-xs text-slate-400 font-medium mb-1 block">Kontak Person</label>
                        <input type="text" value={data.kontak_person} onChange={e => setData('kontak_person', e.target.value)} className={inputClass} placeholder="Bapak/Ibu ..." />
                    </div>
                    <div>
                        <label className="text-xs text-slate-400 font-medium mb-1 block">Alamat</label>
                        <textarea value={data.alamat} onChange={e => setData('alamat', e.target.value)} className={inputClass + ' h-20 resize-none'} placeholder="Jl. ..." />
                    </div>
                    <div>
                        <label className="text-xs text-slate-400 font-medium mb-1 block">Lead Time Rata-rata (hari)</label>
                        <input type="number" value={data.lead_time_rata_rata} onChange={e => setData('lead_time_rata_rata', e.target.value)} className={inputClass} min="1" max="365" required />
                        <p className="text-slate-500 text-xs mt-1">Nilai L untuk rumus ROP = (d × L) + SS</p>
                        {errors.lead_time_rata_rata && <p className="text-red-400 text-xs mt-1">{errors.lead_time_rata_rata}</p>}
                    </div>
                    <div className="flex gap-3 pt-2">
                        <button type="submit" disabled={processing} className="flex-1 inline-flex items-center justify-center gap-2 bg-gradient-to-r from-blue-600 to-cyan-500 text-white px-4 py-2.5 rounded-xl text-sm font-semibold disabled:opacity-60">
                            <Save className="w-4 h-4" />
                            {processing ? 'Menyimpan...' : 'Simpan'}
                        </button>
                        <button type="button" onClick={onClose} className="px-4 py-2.5 text-slate-400 hover:text-white rounded-xl hover:bg-slate-800 transition-all text-sm">Batal</button>
                    </div>
                </form>
            </div>
        </div>
    );
}

export default function SupplierIndex({ suppliers, user }) {
    const [modal, setModal] = useState(null); // null | 'add' | supplier object

    const handleDelete = (id, nama) => {
        if (confirm(`Hapus supplier "${nama}"?`)) {
            router.delete(`/admin/suppliers/${id}`);
        }
    };

    return (
        <AdminLayout user={user} title="Manajemen Supplier">
            <Head title="Supplier — Budi Variasi Admin" />

            <div className="flex items-center justify-between mb-6">
                <div>
                    <h2 className="text-white font-extrabold text-xl">Daftar Supplier</h2>
                    <p className="text-slate-400 text-sm">{suppliers.length} supplier terdaftar</p>
                </div>
                <button onClick={() => setModal('add')} className="inline-flex items-center gap-2 bg-gradient-to-r from-blue-600 to-cyan-500 text-white px-5 py-2.5 rounded-xl text-sm font-semibold shadow-lg shadow-blue-500/20">
                    <Plus className="w-4 h-4" /> Tambah Supplier
                </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {suppliers.map((s) => (
                    <div key={s.id_supplier} className="bg-slate-900 border border-white/5 rounded-2xl p-5 hover:border-white/10 transition-colors">
                        <div className="flex items-start justify-between mb-3">
                            <div className="flex-1 min-w-0">
                                <h3 className="text-white font-bold text-sm truncate">{s.nama_supplier}</h3>
                                <p className="text-slate-400 text-xs mt-0.5">{s.kontak_person ?? '—'}</p>
                            </div>
                            <div className="flex gap-1 ml-2">
                                <button onClick={() => setModal(s)} className="p-1.5 text-slate-500 hover:text-cyan-400 hover:bg-cyan-500/10 rounded-lg transition-all">
                                    <Pencil className="w-3.5 h-3.5" />
                                </button>
                                <button onClick={() => handleDelete(s.id_supplier, s.nama_supplier)} className="p-1.5 text-slate-500 hover:text-red-400 hover:bg-red-500/10 rounded-lg transition-all">
                                    <Trash2 className="w-3.5 h-3.5" />
                                </button>
                            </div>
                        </div>
                        <p className="text-slate-500 text-xs mb-3 line-clamp-2">{s.alamat ?? 'Alamat belum diisi'}</p>
                        <div className="flex items-center justify-between">
                            <span className="inline-flex items-center gap-1.5 bg-cyan-500/10 text-cyan-400 border border-cyan-500/20 px-2.5 py-1 rounded-full text-xs font-semibold">
                                Lead Time: {s.lead_time_rata_rata} hari
                            </span>
                            <span className="text-slate-500 text-xs">{s.products_count ?? 0} produk</span>
                        </div>
                    </div>
                ))}
            </div>

            {(modal === 'add' || typeof modal === 'object') && modal !== null && (
                <SupplierModal
                    onClose={() => setModal(null)}
                    editData={modal !== 'add' ? modal : null}
                />
            )}
        </AdminLayout>
    );
}
