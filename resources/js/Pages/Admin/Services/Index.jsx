import React, { useState } from 'react';
import { Head, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, Pencil, Trash2, X, Save, Eye, EyeOff, ExternalLink } from 'lucide-react';

const inputClass = "w-full bg-[#0a0a0f] border border-white/[0.07] text-slate-200 placeholder-slate-700 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-teal-500/30 focus:ring-1 focus:ring-teal-500/10 transition-all";

function ServiceModal({ onClose, editData }) {
    const isEdit = !!editData;
    const [data, setData] = useState({
        title:       editData?.title       ?? '',
        description: editData?.description ?? '',
        image:       editData?.image       ?? '',
        is_active:   editData?.is_active   ?? true,
        sort_order:  editData?.sort_order  ?? 0,
    });
    const [saving, setSaving] = useState(false);

    const submit = (e) => {
        e.preventDefault();
        setSaving(true);
        const opts = { onSuccess: () => { setSaving(false); onClose(); }, onError: () => setSaving(false), preserveScroll: true };
        if (isEdit) {
            router.post(`/admin/services/${editData.id}`, {
                ...data,
                _method: 'PUT'
            }, opts);
        } else {
            router.post('/admin/services', data, opts);
        }
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose} />
            <div className="relative bg-[#0f0f18] border border-white/10 rounded-2xl p-6 w-full max-w-lg shadow-2xl">
                <div className="flex items-center justify-between mb-5">
                    <h3 className="text-white font-bold text-sm">{isEdit ? 'Edit Layanan' : 'Tambah Layanan'}</h3>
                    <button onClick={onClose} className="text-slate-500 hover:text-white"><X className="w-4 h-4" /></button>
                </div>
                <form onSubmit={submit} className="space-y-4">
                    <div>
                        <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Nama Layanan</label>
                        <input type="text" value={data.title} onChange={e => setData({...data, title: e.target.value})} className={inputClass} placeholder="Kaca Film" required />
                    </div>
                    <div>
                        <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Deskripsi</label>
                        <textarea value={data.description} onChange={e => setData({...data, description: e.target.value})} className={inputClass + ' h-20 resize-none'} placeholder="Deskripsi singkat layanan..." />
                    </div>
                    <div>
                        <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Gambar Layanan</label>
                        
                        {data.image && (
                            <div className="mb-3 relative rounded-xl overflow-hidden border border-white/10 h-32 bg-black/40 flex items-center justify-center group">
                                <img 
                                    src={typeof data.image === 'string' ? data.image : URL.createObjectURL(data.image)} 
                                    alt="Preview" 
                                    className="h-full w-full object-cover opacity-80" 
                                />
                                <button 
                                    type="button" 
                                    onClick={() => setData({...data, image: ''})} 
                                    className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 flex items-center justify-center text-white text-xs font-semibold transition-all"
                                >
                                    Hapus Gambar
                                </button>
                            </div>
                        )}

                        <div className="flex items-center justify-center w-full">
                            <label className="flex flex-col items-center justify-center w-full h-24 border border-dashed border-white/[0.07] hover:border-teal-500/30 rounded-xl cursor-pointer hover:bg-white/[0.01] transition-all">
                                <div className="flex flex-col items-center justify-center pt-5 pb-6">
                                    <p className="text-xs text-slate-400 font-semibold text-center">Klik untuk upload gambar</p>
                                    <p className="text-[10px] text-slate-600 mt-1">PNG, JPG, JPEG, WEBP (Maks. 2MB)</p>
                                </div>
                                <input 
                                    type="file" 
                                    className="hidden" 
                                    accept="image/*" 
                                    onChange={e => {
                                        if (e.target.files && e.target.files[0]) {
                                            setData({...data, image: e.target.files[0]});
                                        }
                                    }} 
                                />
                            </label>
                        </div>
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Urutan Tampil</label>
                            <input type="number" value={data.sort_order} onChange={e => setData({...data, sort_order: parseInt(e.target.value)})} className={inputClass} min="0" />
                        </div>
                        <div>
                            <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Status</label>
                            <select value={data.is_active} onChange={e => setData({...data, is_active: e.target.value === 'true'})} className={inputClass}>
                                <option value="true">Aktif (tampil)</option>
                                <option value="false">Nonaktif</option>
                            </select>
                        </div>
                    </div>
                    <div className="flex gap-2 pt-1">
                        <button type="submit" disabled={saving} className="flex-1 flex items-center justify-center gap-2 bg-teal-600 hover:bg-teal-500 text-white py-2.5 rounded-xl text-xs font-semibold disabled:opacity-50 transition-colors">
                            <Save className="w-3.5 h-3.5" />
                            {saving ? 'Menyimpan...' : 'Simpan Layanan'}
                        </button>
                        <button type="button" onClick={onClose} className="px-4 text-slate-500 hover:text-white rounded-xl hover:bg-white/[0.05] transition-all text-xs">Batal</button>
                    </div>
                </form>
            </div>
        </div>
    );
}

export default function ServiceIndex({ services, user }) {
    const [modal, setModal] = useState(null);

    const handleDelete = (id, title) => {
        if (confirm(`Hapus layanan "${title}"?`)) {
            router.delete(`/admin/services/${id}`, { preserveScroll: true });
        }
    };

    return (
        <AdminLayout user={user} title="Kelola Layanan Jasa">
            <Head title="Layanan Jasa — Budi Variasi Admin" />

            <div className="flex items-center justify-between mb-6">
                <div>
                    <h2 className="text-white font-bold text-sm">Kelola Layanan Jasa</h2>
                    <p className="text-slate-600 text-xs mt-0.5">Data ini ditampilkan di Landing Page — {services.length} layanan terdaftar</p>
                </div>
                <button
                    onClick={() => setModal('add')}
                    className="inline-flex items-center gap-1.5 bg-teal-600 hover:bg-teal-500 text-white px-3.5 py-2 rounded-xl text-xs font-semibold transition-colors flex-shrink-0"
                >
                    <Plus className="w-3.5 h-3.5" />
                    Tambah Layanan
                </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {services.length === 0 ? (
                    <div className="col-span-3 bg-[#0f0f18] border border-dashed border-white/[0.06] rounded-2xl px-6 py-12 text-center">
                        <p className="text-slate-600 text-xs">Belum ada layanan. Tambahkan layanan pertama.</p>
                    </div>
                ) : services.map(s => (
                    <div key={s.id} className="bg-[#0f0f18] border border-white/[0.05] rounded-2xl overflow-hidden hover:border-white/[0.08] transition-all group">
                        {s.image && (
                            <div className="h-32 overflow-hidden">
                                <img src={s.image} alt={s.title} className="w-full h-full object-cover opacity-60 group-hover:opacity-80 transition-opacity" />
                            </div>
                        )}
                        <div className="p-4">
                            <div className="flex items-start justify-between mb-2">
                                <div className="flex-1 min-w-0">
                                    <h3 className="text-slate-200 text-xs font-bold truncate">{s.title}</h3>
                                    <span className={`inline-flex items-center gap-1 mt-1 text-[10px] font-semibold ${s.is_active ? 'text-teal-400' : 'text-slate-600'}`}>
                                        {s.is_active ? <Eye className="w-2.5 h-2.5" /> : <EyeOff className="w-2.5 h-2.5" />}
                                        {s.is_active ? 'Tampil di Landing Page' : 'Nonaktif'}
                                    </span>
                                </div>
                                <div className="flex gap-1 ml-2 flex-shrink-0">
                                    <button onClick={() => setModal(s)} className="p-1.5 text-slate-500 hover:text-teal-400 hover:bg-teal-500/10 rounded-lg transition-all">
                                        <Pencil className="w-3 h-3" />
                                    </button>
                                    <button onClick={() => handleDelete(s.id, s.title)} className="p-1.5 text-slate-500 hover:text-red-400 hover:bg-red-500/10 rounded-lg transition-all">
                                        <Trash2 className="w-3 h-3" />
                                    </button>
                                </div>
                            </div>
                            {s.description && <p className="text-slate-600 text-[10px] line-clamp-2 leading-relaxed">{s.description}</p>}
                            <div className="mt-3 flex items-center justify-between text-[10px] text-slate-700">
                                <span>Urutan: {s.sort_order}</span>
                                <a href="/" target="_blank" className="flex items-center gap-1 hover:text-slate-400 transition-colors">
                                    Lihat Landing Page <ExternalLink className="w-2.5 h-2.5" />
                                </a>
                            </div>
                        </div>
                    </div>
                ))}
            </div>

            {(modal === 'add' || (modal && typeof modal === 'object')) && (
                <ServiceModal onClose={() => setModal(null)} editData={modal !== 'add' ? modal : null} />
            )}
        </AdminLayout>
    );
}
