import React, { useState } from 'react';
import { Head, router } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, Trash2, Eye, EyeOff, Star, X, Save } from 'lucide-react';

const inputClass = "w-full bg-[#0a0a0f] border border-white/[0.07] text-slate-200 placeholder-slate-700 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-indigo-500/30 focus:ring-1 focus:ring-indigo-500/10 transition-all";

function AddModal({ onClose }) {
    const [data, setData] = useState({ name: '', review_text: '', rating: 5, is_displayed: true });
    const [saving, setSaving] = useState(false);

    const submit = (e) => {
        e.preventDefault();
        setSaving(true);
        router.post('/admin/testimonials', data, {
            onSuccess: () => { setSaving(false); onClose(); },
            onError: () => setSaving(false),
            preserveScroll: true,
        });
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose} />
            <div className="relative bg-[#0f0f18] border border-white/10 rounded-2xl p-6 w-full max-w-md shadow-2xl">
                <div className="flex items-center justify-between mb-5">
                    <h3 className="text-white font-bold text-sm">Tambah Testimoni</h3>
                    <button onClick={onClose} className="text-slate-500 hover:text-white"><X className="w-4 h-4" /></button>
                </div>
                <form onSubmit={submit} className="space-y-4">
                    <div>
                        <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Nama Pelanggan</label>
                        <input type="text" value={data.name} onChange={e => setData({...data, name: e.target.value})} className={inputClass} placeholder="Nama pelanggan..." required />
                    </div>
                    <div>
                        <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Ulasan</label>
                        <textarea value={data.review_text} onChange={e => setData({...data, review_text: e.target.value})} className={inputClass + ' h-24 resize-none'} placeholder="Tulis ulasan pelanggan..." required />
                    </div>
                    <div>
                        <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Rating (1–5 Bintang)</label>
                        <div className="flex gap-2">
                            {[1,2,3,4,5].map(n => (
                                <button key={n} type="button" onClick={() => setData({...data, rating: n})}
                                    className={`p-2 rounded-lg transition-all ${data.rating >= n ? 'text-yellow-400' : 'text-slate-700'}`}>
                                    <Star className={`w-5 h-5 ${data.rating >= n ? 'fill-current' : ''}`} />
                                </button>
                            ))}
                        </div>
                    </div>
                    <label className="flex items-center gap-2.5 cursor-pointer">
                        <input type="checkbox" checked={data.is_displayed} onChange={e => setData({...data, is_displayed: e.target.checked})} className="sr-only peer" />
                        <div className="w-4 h-4 rounded border border-white/10 bg-white/[0.04] peer-checked:bg-indigo-600 peer-checked:border-indigo-600 transition-all flex items-center justify-center">
                            {data.is_displayed && <svg className="w-2.5 h-2.5 text-white" fill="none" viewBox="0 0 12 12"><path d="M2 6l3 3 5-5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>}
                        </div>
                        <span className="text-xs text-slate-400">Tampilkan di Landing Page</span>
                    </label>
                    <div className="flex gap-2 pt-1">
                        <button type="submit" disabled={saving} className="flex-1 flex items-center justify-center gap-2 bg-indigo-600 hover:bg-indigo-500 text-white py-2.5 rounded-xl text-xs font-semibold disabled:opacity-50 transition-colors">
                            <Save className="w-3.5 h-3.5" />
                            {saving ? 'Menyimpan...' : 'Tambah Testimoni'}
                        </button>
                        <button type="button" onClick={onClose} className="px-4 text-slate-500 hover:text-white rounded-xl hover:bg-white/[0.05] text-xs">Batal</button>
                    </div>
                </form>
            </div>
        </div>
    );
}

export default function TestimonialIndex({ testimonials, user }) {
    const [showAdd, setShowAdd] = useState(false);

    const handleToggle = (id, currentStatus) => {
        router.put(`/admin/testimonials/${id}/toggle`, {}, { preserveScroll: true });
    };

    const handleDelete = (id, name) => {
        if (confirm(`Hapus testimoni dari "${name}"?`)) {
            router.delete(`/admin/testimonials/${id}`, { preserveScroll: true });
        }
    };

    const displayed = testimonials.filter(t => t.is_displayed).length;

    return (
        <AdminLayout user={user} title="Kelola Testimoni">
            <Head title="Testimoni — Budi Variasi Admin" />

            <div className="flex items-center justify-between mb-6">
                <div>
                    <h2 className="text-white font-bold text-sm">Validasi Ulasan Pelanggan</h2>
                    <p className="text-slate-600 text-xs mt-0.5">
                        {testimonials.length} total ulasan · <span className="text-indigo-400">{displayed} ditampilkan</span> di Landing Page
                    </p>
                </div>
                <button
                    onClick={() => setShowAdd(true)}
                    className="inline-flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-500 text-white px-3.5 py-2 rounded-xl text-xs font-semibold transition-colors flex-shrink-0"
                >
                    <Plus className="w-3.5 h-3.5" />
                    Tambah Manual
                </button>
            </div>

            <div className="bg-[#0f0f18] border border-white/[0.05] rounded-2xl overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead>
                            <tr className="border-b border-white/[0.04]">
                                {['Pelanggan', 'Ulasan', 'Rating', 'Sumber', 'Status Tampil', 'Aksi'].map((h, i) => (
                                    <th key={i} className={`px-4 py-3 text-[10px] font-semibold text-slate-600 uppercase tracking-widest ${i < 2 ? 'text-left' : 'text-center'}`}>
                                        {h}
                                    </th>
                                ))}
                            </tr>
                        </thead>
                        <tbody>
                            {testimonials.length === 0 ? (
                                <tr>
                                    <td colSpan={6} className="px-4 py-12 text-center text-slate-700 text-xs">
                                        Belum ada ulasan. Tambahkan secara manual atau sinkronisasi dari Google Maps.
                                    </td>
                                </tr>
                            ) : testimonials.map(t => (
                                <tr key={t.id} className={`border-b border-white/[0.03] last:border-0 hover:bg-white/[0.01] transition-colors ${t.is_displayed ? '' : 'opacity-50'}`}>
                                    <td className="px-4 py-3.5">
                                        <div className="flex items-center gap-2.5">
                                            {t.profile_photo_url ? (
                                                <img src={t.profile_photo_url} alt={t.name} className="w-7 h-7 rounded-full object-cover" />
                                            ) : (
                                                <div className="w-7 h-7 rounded-full bg-indigo-900/40 flex items-center justify-center text-indigo-400 text-[10px] font-bold flex-shrink-0">
                                                    {t.name?.charAt(0)}
                                                </div>
                                            )}
                                            <div>
                                                <p className="text-slate-200 text-xs font-semibold">{t.name}</p>
                                                {t.relative_time_description && <p className="text-slate-600 text-[10px]">{t.relative_time_description}</p>}
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-4 py-3.5 max-w-[280px]">
                                        <p className="text-slate-400 text-[11px] line-clamp-2 leading-relaxed">"{t.review_text}"</p>
                                    </td>
                                    <td className="px-4 py-3.5 text-center">
                                        <div className="flex justify-center gap-0.5">
                                            {[1,2,3,4,5].map(n => (
                                                <Star key={n} className={`w-3 h-3 ${n <= t.rating ? 'text-yellow-400 fill-current' : 'text-slate-700'}`} />
                                            ))}
                                        </div>
                                    </td>
                                    <td className="px-4 py-3.5 text-center">
                                        <span className="text-slate-500 text-[10px]">{t.source ?? 'Manual'}</span>
                                    </td>
                                    <td className="px-4 py-3.5 text-center">
                                        <button
                                            onClick={() => handleToggle(t.id, t.is_displayed)}
                                            className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-semibold border transition-all ${
                                                t.is_displayed
                                                    ? 'bg-indigo-500/8 text-indigo-400 border-indigo-500/15 hover:bg-red-500/8 hover:text-red-400 hover:border-red-500/15'
                                                    : 'bg-slate-500/8 text-slate-500 border-slate-500/15 hover:bg-indigo-500/8 hover:text-indigo-400 hover:border-indigo-500/15'
                                            }`}
                                            title={t.is_displayed ? 'Klik untuk sembunyikan' : 'Klik untuk tampilkan'}
                                        >
                                            {t.is_displayed ? <><Eye className="w-2.5 h-2.5" /> Tampil</> : <><EyeOff className="w-2.5 h-2.5" /> Tersembunyi</>}
                                        </button>
                                    </td>
                                    <td className="px-4 py-3.5 text-center">
                                        <button
                                            onClick={() => handleDelete(t.id, t.name)}
                                            className="p-1.5 text-slate-500 hover:text-red-400 hover:bg-red-500/10 rounded-lg transition-all"
                                        >
                                            <Trash2 className="w-3.5 h-3.5" />
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>

            {showAdd && <AddModal onClose={() => setShowAdd(false)} />}
        </AdminLayout>
    );
}
