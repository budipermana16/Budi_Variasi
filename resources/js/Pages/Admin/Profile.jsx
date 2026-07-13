import React from 'react';
import { Head, useForm } from '@inertiajs/react';
import AdminLayout from '@/Layouts/AdminLayout';
import { User, Mail, Shield, Save, Key, CheckCircle, Info } from 'lucide-react';

const inputClass = "w-full bg-[#0a0a0f] border border-white/[0.07] text-slate-200 placeholder-slate-700 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-sky-500/30 focus:ring-1 focus:ring-sky-500/10 transition-all";

export default function Profile({ user, flash = {} }) {
    // Form untuk informasi profil
    const infoForm = useForm({
        name: user.name,
        email: user.email,
        current_password: '',
        new_password: '',
    });

    const handleUpdateProfile = (e) => {
        e.preventDefault();
        infoForm.put('/admin/profile', {
            preserveScroll: true,
            onSuccess: () => {
                infoForm.reset('current_password', 'new_password');
            }
        });
    };

    return (
        <AdminLayout user={user} title="Profil Saya">
            <Head title="Profil Saya — Budi Variasi Admin" />

            <div className="max-w-2xl mx-auto space-y-6">
                <div>
                    <h2 className="text-white font-bold text-sm">Pengaturan Akun</h2>
                    <p className="text-slate-600 text-xs mt-0.5">
                        Kelola data profil pribadi Anda dan perbarui kata sandi akun Anda secara berkala.
                    </p>
                </div>

                {/* Status Sukses */}
                {flash?.success && (
                    <div className="flex items-center gap-3 px-4.5 py-3.5 bg-emerald-500/8 border border-emerald-500/15 rounded-xl text-emerald-400 text-xs font-medium">
                        <CheckCircle className="w-4 h-4 flex-shrink-0" />
                        <span>{flash.success}</span>
                    </div>
                )}

                {/* Main Card */}
                <div className="bg-[#0f0f18] border border-white/[0.05] rounded-2xl shadow-xl overflow-hidden">
                    {/* Header Banner */}
                    <div className="h-20 bg-gradient-to-r from-sky-600/20 to-blue-600/10 border-b border-white/[0.03] flex items-center px-6">
                        <div className="flex items-center gap-3.5">
                            <div className="w-12 h-12 bg-sky-500/10 border border-sky-500/20 rounded-xl flex items-center justify-center text-sky-400 text-sm font-bold shadow-lg shadow-sky-500/5">
                                {user.name?.charAt(0)?.toUpperCase()}
                            </div>
                            <div>
                                <h3 className="text-slate-200 text-xs font-bold leading-tight">{user.name}</h3>
                                <p className="text-slate-500 text-[10px] uppercase tracking-wider font-semibold mt-0.5">
                                    Role: {user.role === 'owner' ? 'Owner' : 'Admin Gudang'}
                                </p>
                            </div>
                        </div>
                    </div>

                    <div className="p-6">
                        <form onSubmit={handleUpdateProfile} className="space-y-5">
                            <h4 className="text-[10px] font-bold text-slate-500 uppercase tracking-widest border-b border-white/5 pb-2 flex items-center gap-1.5">
                                <User className="w-3.5 h-3.5 text-sky-400" />
                                Informasi Profil
                            </h4>

                            {/* Nama */}
                            <div>
                                <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Nama Lengkap</label>
                                <input
                                    type="text"
                                    value={infoForm.data.name}
                                    onChange={e => infoForm.setData('name', e.target.value)}
                                    className={inputClass}
                                    placeholder="Nama lengkap..."
                                    required
                                />
                                {infoForm.errors.name && <p className="text-red-400 text-xs mt-1">{infoForm.errors.name}</p>}
                            </div>

                            {/* Email */}
                            <div>
                                <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Alamat Email</label>
                                <div className="relative">
                                    <input
                                        type="email"
                                        value={infoForm.data.email}
                                        onChange={e => infoForm.setData('email', e.target.value)}
                                        className={inputClass + " pl-10"}
                                        placeholder="Alamat email..."
                                        required
                                    />
                                    <Mail className="absolute left-3.5 top-3.5 w-4 h-4 text-slate-600" />
                                </div>
                                {infoForm.errors.email && <p className="text-red-400 text-xs mt-1">{infoForm.errors.email}</p>}
                            </div>

                            <h4 className="text-[10px] font-bold text-slate-500 uppercase tracking-widest border-b border-white/5 pb-2 pt-3 flex items-center gap-1.5">
                                <Key className="w-3.5 h-3.5 text-sky-400" />
                                Ubah Password
                            </h4>

                            <div className="bg-sky-500/5 border border-sky-500/10 rounded-xl p-3 flex gap-2.5">
                                <Info className="w-4 h-4 text-sky-400 flex-shrink-0 mt-0.5" />
                                <p className="text-slate-500 text-[10px] leading-relaxed">
                                    Isi bagian ini hanya jika Anda ingin memperbarui password. Jika tidak, kosongkan kolom password lama & baru di bawah.
                                </p>
                            </div>

                            {/* Password Saat Ini */}
                            <div>
                                <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Password Saat Ini</label>
                                <input
                                    type="password"
                                    value={infoForm.data.current_password}
                                    onChange={e => infoForm.setData('current_password', e.target.value)}
                                    className={inputClass}
                                    placeholder="Masukkan password saat ini untuk verifikasi"
                                    required={infoForm.data.new_password.length > 0}
                                />
                                {infoForm.errors.current_password && <p className="text-red-400 text-xs mt-1">{infoForm.errors.current_password}</p>}
                            </div>

                            {/* Password Baru */}
                            <div>
                                <label className="block text-[10px] font-semibold text-slate-500 uppercase tracking-widest mb-1.5">Password Baru</label>
                                <input
                                    type="password"
                                    value={infoForm.data.new_password}
                                    onChange={e => infoForm.setData('new_password', e.target.value)}
                                    className={inputClass}
                                    placeholder="Masukkan password baru (min 6 karakter)"
                                    required={infoForm.data.current_password.length > 0}
                                />
                                {infoForm.errors.new_password && <p className="text-red-400 text-xs mt-1">{infoForm.errors.new_password}</p>}
                            </div>

                            <div className="pt-2">
                                <button
                                    type="submit"
                                    disabled={infoForm.processing}
                                    className="w-full flex items-center justify-center gap-2 bg-sky-600 hover:bg-sky-500 active:bg-sky-700 text-white py-2.5 rounded-xl text-xs font-semibold disabled:opacity-50 transition-colors shadow-lg shadow-sky-500/10"
                                >
                                    <Save className="w-3.5 h-3.5" />
                                    {infoForm.processing ? 'Menyimpan...' : 'Simpan Pengaturan'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </AdminLayout>
    );
}
