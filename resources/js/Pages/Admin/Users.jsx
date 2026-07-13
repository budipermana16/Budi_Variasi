import React, { useState } from 'react';
import { Head, router, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { Plus, Trash2, Edit2, X, Save, Shield, UserCog, Mail, Key } from 'lucide-react';
import { cardBg, cardCls, inputCls, PageHeader, BtnPrimary } from '@/Lib/ui';

function UserModal({ user, onClose }) {
    const isEdit = !!user;
    const { data, setData, post, put, processing, errors, reset } = useForm({
        name:     user?.name  || '',
        email:    user?.email || '',
        password: '',
        role:     user?.role  || 'admin_gudang',
    });

    const submit = (e) => {
        e.preventDefault();
        if (isEdit) {
            put(`/admin/users/${user.id}`, { onSuccess: onClose, preserveScroll: true });
        } else {
            post('/admin/users', { onSuccess: () => { reset(); onClose(); }, preserveScroll: true });
        }
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/70 backdrop-blur-sm" onClick={onClose} />
            <div
                className="relative rounded-3xl border border-slate-850 p-6 w-full max-w-md shadow-2xl z-10"
                style={{ backgroundColor: cardBg }}
            >
                <div className="flex items-center justify-between mb-5">
                    <div>
                        <h3 className="text-white font-bold text-sm tracking-wide">
                            {isEdit ? 'Edit Akun Pengguna' : 'Tambah Akun Baru'}
                        </h3>
                        <p className="text-slate-500 text-[10px] font-medium mt-0.5">Tentukan hak akses untuk panel admin</p>
                    </div>
                    <button onClick={onClose} className="p-1.5 text-slate-500 hover:text-white hover:bg-slate-800 rounded-xl transition-all">
                        <X className="w-4 h-4" />
                    </button>
                </div>

                <form onSubmit={submit} className="space-y-4">
                    <div>
                        <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Nama Lengkap</label>
                        <input type="text" value={data.name} onChange={e => setData('name', e.target.value)}
                            className={inputCls} placeholder="Nama lengkap staf" required />
                        {errors.name && <p className="text-rose-400 text-[10px] mt-1 font-semibold">{errors.name}</p>}
                    </div>

                    <div>
                        <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Email</label>
                        <div className="relative">
                            <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-600" />
                            <input type="email" value={data.email} onChange={e => setData('email', e.target.value)}
                                className={inputCls + ' pl-10'}
                                placeholder="nama@budivariasi.com" required />
                        </div>
                        {errors.email && <p className="text-rose-400 text-[10px] mt-1 font-semibold">{errors.email}</p>}
                    </div>

                    <div>
                        <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">
                            Password {isEdit && <span className="text-slate-600 font-normal lowercase">(kosongkan jika tidak diubah)</span>}
                        </label>
                        <div className="relative">
                            <Key className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-600" />
                            <input type="password" value={data.password} onChange={e => setData('password', e.target.value)}
                                className={inputCls + ' pl-10'}
                                placeholder="••••••••" required={!isEdit} />
                        </div>
                        {errors.password && <p className="text-rose-400 text-[10px] mt-1 font-semibold">{errors.password}</p>}
                    </div>

                    <div>
                        <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Peran / Hak Akses</label>
                        <select value={data.role} onChange={e => setData('role', e.target.value)}
                            className={inputCls} required>
                            <option value="owner">Owner (Pemilik Toko)</option>
                            <option value="admin_gudang">Admin Gudang (Staf)</option>
                        </select>
                        {errors.role && <p className="text-rose-400 text-[10px] mt-1 font-semibold">{errors.role}</p>}
                    </div>

                    <div className="flex gap-3 pt-2">
                        <button type="submit" disabled={processing}
                            className="flex-1 flex items-center justify-center gap-2 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white py-2.5 rounded-xl text-xs font-bold disabled:opacity-50 transition-all shadow-md shadow-blue-500/10">
                            <Save className="w-4 h-4" />
                            {processing ? 'Menyimpan...' : (isEdit ? 'Simpan Akun' : 'Daftarkan Akun')}
                        </button>
                        <button type="button" onClick={onClose}
                            className="px-4 text-slate-400 hover:text-white hover:bg-slate-800 rounded-xl text-xs font-bold transition-all">
                            Batal
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}

export default function UsersIndex({ users, auth_user_id, user }) {
    const [showAdd, setShowAdd]   = useState(false);
    const [editUser, setEditUser] = useState(null);

    const handleDelete = (target) => {
        if (target.id === auth_user_id) {
            alert('Anda tidak dapat menghapus akun Anda sendiri.');
            return;
        }
        if (confirm(`Apakah Anda yakin ingin menghapus akun "${target.name}"?`)) {
            router.delete(`/admin/users/${target.id}`, { preserveScroll: true });
        }
    };

    return (
        <AdminLayout user={user} title="Kelola Pengguna">
            <Head title="Kelola User — Budi Variasi" />

            {/* Header */}
            <PageHeader
                title="Kelola Pengguna & Hak Akses"
                subtitle="Daftar akun staf admin gudang dan owner pemilik toko"
                action={
                    <BtnPrimary onClick={() => setShowAdd(true)} color="blue">
                        <Plus className="w-4 h-4" /> Tambah Pengguna
                    </BtnPrimary>
                }
            />

            {/* User Cards Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {users.map(u => {
                    const isSelf = u.id === auth_user_id;
                    const isOwner = u.role === 'owner';
                    
                    return (
                        <div
                            key={u.id}
                            className={`${cardCls} relative p-6 transition-all duration-300 hover:-translate-y-1 hover:border-slate-700/80 group`}
                            style={{ backgroundColor: cardBg }}
                        >
                            {/* Role Badge and Actions */}
                            <div className="flex items-center justify-between mb-5">
                                {isOwner ? (
                                    <span className="inline-flex items-center gap-1 bg-rose-500/10 text-rose-400 border border-rose-500/20 text-[9px] font-bold px-2 py-0.5 rounded-md uppercase tracking-wider">
                                        <Shield className="w-3 h-3" /> Owner
                                    </span>
                                ) : (
                                    <span className="inline-flex items-center gap-1 bg-blue-500/10 text-blue-400 border border-blue-500/20 text-[9px] font-bold px-2 py-0.5 rounded-md uppercase tracking-wider">
                                        <UserCog className="w-3 h-3" /> Admin Gudang
                                    </span>
                                )}

                                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                                    <button
                                        onClick={() => setEditUser(u)}
                                        className="p-1.5 text-slate-500 hover:text-blue-400 hover:bg-blue-500/10 rounded-lg transition-all"
                                        title="Edit Akun"
                                    >
                                        <Edit2 className="w-3.5 h-3.5" />
                                    </button>
                                    {!isSelf && (
                                        <button
                                            onClick={() => handleDelete(u)}
                                            className="p-1.5 text-slate-500 hover:text-rose-400 hover:bg-rose-500/10 rounded-lg transition-all"
                                            title="Hapus Akun"
                                        >
                                            <Trash2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                </div>
                            </div>

                            {/* User Main Info */}
                            <div className="flex items-center gap-4">
                                <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-blue-500 to-indigo-600 flex items-center justify-center text-white text-base font-extrabold shadow-lg shadow-blue-500/20 flex-shrink-0">
                                    {u.name?.charAt(0)?.toUpperCase()}
                                </div>
                                <div className="min-w-0">
                                    <div className="flex items-center gap-1.5">
                                        <h4 className="text-white text-sm font-bold truncate tracking-wide">{u.name}</h4>
                                        {isSelf && (
                                            <span className="bg-emerald-500/15 text-emerald-400 border border-emerald-500/20 text-[8px] px-1 py-0.5 rounded font-bold uppercase tracking-wider">
                                                Anda
                                            </span>
                                        )}
                                    </div>
                                    <p className="text-slate-500 text-xs truncate mt-0.5">{u.email}</p>
                                </div>
                            </div>

                            {/* Card Footer Decoration / Subtle Info */}
                            <div className="mt-5 pt-4 border-t border-slate-900 flex justify-between items-center text-[10px] text-slate-600 font-medium">
                                <span>Status Akun</span>
                                <span className="text-emerald-400 flex items-center gap-1">
                                    <span className="w-1.5 h-1.5 bg-emerald-400 rounded-full" />
                                    Aktif
                                </span>
                            </div>
                        </div>
                    );
                })}
            </div>

            {showAdd  && <UserModal onClose={() => setShowAdd(false)} />}
            {editUser && <UserModal user={editUser} onClose={() => setEditUser(null)} />}
        </AdminLayout>
    );
}
