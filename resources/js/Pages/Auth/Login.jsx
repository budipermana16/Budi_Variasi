import React, { useState } from 'react';
import { Head, useForm, Link } from '@inertiajs/react';
import { Eye, EyeOff, ArrowRight, TrendingUp, ArrowLeft } from 'lucide-react';

export default function Login() {
    const [showPass, setShowPass] = useState(false);
    const { data, setData, post, processing, errors } = useForm({
        email: '',
        password: '',
        remember: false,
    });

    const submit = (e) => {
        e.preventDefault();
        post('/admin/login');
    };

    return (
        <div className="min-h-screen bg-[#070710] flex">
            <Head title="Login — Budi Variasi Admin" />

            {/* Left panel - branding */}
            <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden flex-col items-center justify-center p-16">
                {/* Background grid */}
                <div className="absolute inset-0"
                    style={{
                        backgroundImage: `radial-gradient(circle at 1px 1px, rgba(255,255,255,0.03) 1px, transparent 0)`,
                        backgroundSize: '32px 32px'
                    }}
                />
                {/* Glow orb */}
                <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-blue-600/10 rounded-full blur-[80px] pointer-events-none" />

                <div className="relative z-10 text-center">
                    <div className="inline-flex items-center justify-center w-14 h-14 bg-blue-600/10 border border-blue-500/20 rounded-2xl mb-8">
                        <TrendingUp className="w-6 h-6 text-blue-400" />
                    </div>
                    <h2 className="text-4xl font-black text-white tracking-tight leading-tight mb-4">
                        Inventory<br/>
                        <span className="text-blue-400">Control</span> System
                    </h2>
                    <p className="text-slate-400 text-sm leading-relaxed max-w-xs mx-auto">
                        Sistem manajemen inventory berbasis Regresi Linear untuk penentuan Reorder Point otomatis.
                    </p>
                    <div className="mt-10 flex flex-col gap-3 text-left">
                        {[
                            { label: 'Regresi Linear', sub: 'Prediksi penjualan bulan depan' },
                            { label: 'Reorder Point', sub: 'Notifikasi stok otomatis' },
                            { label: 'Real-time Sync', sub: 'Status update langsung' },
                        ].map(f => (
                            <div key={f.label} className="flex items-center gap-3 px-4 py-3 bg-white/[0.03] border border-white/[0.05] rounded-xl">
                                <div className="w-1.5 h-1.5 bg-blue-400 rounded-full flex-shrink-0" />
                                <div>
                                    <p className="text-white text-xs font-semibold">{f.label}</p>
                                    <p className="text-slate-500 text-[10px]">{f.sub}</p>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            {/* Right panel - form */}
            <div className="flex-1 flex items-center justify-center px-6 py-12 relative">
                <div className="absolute inset-0 lg:hidden"
                    style={{
                        backgroundImage: `radial-gradient(circle at 1px 1px, rgba(255,255,255,0.02) 1px, transparent 0)`,
                        backgroundSize: '28px 28px'
                    }}
                />

                <div className="w-full max-w-sm relative z-10">
                    {/* Mobile brand */}
                    <div className="lg:hidden flex items-center gap-2.5 mb-8">
                        <div className="w-8 h-8 bg-blue-600/15 border border-blue-500/20 rounded-lg flex items-center justify-center">
                            <TrendingUp className="w-4 h-4 text-blue-400" />
                        </div>
                        <span className="text-white font-bold text-sm">Budi Variasi Admin</span>
                    </div>

                    {/* Back to Landing Page Link */}
                    <div className="mb-6">
                        <Link 
                            href="/" 
                            className="inline-flex items-center gap-2 text-xs font-semibold text-slate-500 hover:text-slate-300 transition-colors group"
                        >
                            <ArrowLeft className="w-3.5 h-3.5 group-hover:-translate-x-0.5 transition-transform" />
                            Kembali ke Halaman Utama
                        </Link>
                    </div>

                    <div className="mb-8">
                        <h1 className="text-2xl font-black text-white tracking-tight mb-1">Masuk</h1>
                        <p className="text-slate-500 text-sm">Masukkan kredensial admin Anda</p>
                    </div>

                    <form onSubmit={submit} className="space-y-4">
                        {/* Email */}
                        <div>
                            <label className="block text-xs font-semibold text-slate-400 mb-1.5 uppercase tracking-wide">
                                Email
                            </label>
                            <input
                                id="email"
                                type="email"
                                value={data.email}
                                onChange={e => setData('email', e.target.value)}
                                className="w-full bg-white/[0.04] border border-white/[0.08] text-white placeholder-slate-600 rounded-xl px-4 py-3 text-sm focus:outline-none focus:bg-white/[0.06] focus:border-blue-500/40 focus:ring-1 focus:ring-blue-500/20 transition-all"
                                placeholder="admin@budivariasi.com"
                                autoComplete="email"
                                required
                            />
                            {errors.email && (
                                <p className="text-red-400 text-xs mt-1.5 flex items-center gap-1">
                                    <span className="w-1 h-1 bg-red-400 rounded-full inline-block" />
                                    {errors.email}
                                </p>
                            )}
                        </div>

                        {/* Password */}
                        <div>
                            <label className="block text-xs font-semibold text-slate-400 mb-1.5 uppercase tracking-wide">
                                Password
                            </label>
                            <div className="relative">
                                <input
                                    id="password"
                                    type={showPass ? 'text' : 'password'}
                                    value={data.password}
                                    onChange={e => setData('password', e.target.value)}
                                    className="w-full bg-white/[0.04] border border-white/[0.08] text-white placeholder-slate-600 rounded-xl px-4 py-3 pr-11 text-sm focus:outline-none focus:bg-white/[0.06] focus:border-blue-500/40 focus:ring-1 focus:ring-blue-500/20 transition-all"
                                    placeholder="••••••••"
                                    autoComplete="current-password"
                                    required
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPass(!showPass)}
                                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-600 hover:text-slate-400 transition-colors"
                                    tabIndex={-1}
                                >
                                    {showPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                                </button>
                            </div>
                            {errors.password && (
                                <p className="text-red-400 text-xs mt-1.5 flex items-center gap-1">
                                    <span className="w-1 h-1 bg-red-400 rounded-full inline-block" />
                                    {errors.password}
                                </p>
                            )}
                        </div>

                        {/* Remember */}
                        <label className="flex items-center gap-2.5 cursor-pointer group py-1">
                            <div className="relative flex-shrink-0">
                                <input
                                    type="checkbox"
                                    checked={data.remember}
                                    onChange={e => setData('remember', e.target.checked)}
                                    className="sr-only peer"
                                />
                                <div className="w-4 h-4 rounded border border-white/10 bg-white/[0.04] peer-checked:bg-blue-600 peer-checked:border-blue-600 transition-all flex items-center justify-center">
                                    {data.remember && (
                                        <svg className="w-2.5 h-2.5 text-white" fill="none" viewBox="0 0 12 12">
                                            <path d="M2 6l3 3 5-5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                                        </svg>
                                    )}
                                </div>
                            </div>
                            <span className="text-xs text-slate-500 group-hover:text-slate-400 transition-colors select-none">
                                Ingat saya
                            </span>
                        </label>

                        <button
                            type="submit"
                            disabled={processing}
                            className="w-full flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-500 active:bg-blue-700 text-white font-semibold py-3 rounded-xl text-sm transition-all duration-150 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-blue-500/15 mt-2"
                        >
                            {processing ? (
                                <>
                                    <span className="w-3.5 h-3.5 border border-white/30 border-t-white rounded-full animate-spin" />
                                    Memproses...
                                </>
                            ) : (
                                <>
                                    Masuk ke Panel Admin
                                    <ArrowRight className="w-3.5 h-3.5" />
                                </>
                            )}
                        </button>
                    </form>

                    <p className="text-center text-slate-700 text-[10px] mt-10 tracking-widest uppercase">
                        Budi Variasi Mobil · Ngawi
                    </p>
                </div>
            </div>
        </div>
    );
}
