import React from 'react';
import { Link } from '@inertiajs/react';

// ============================================================
// Konstanta desain bersama — Budi Variasi Mobil Premium Dark
// ============================================================

export const pageBg    = '#080d1a'; // Sangat gelap navy modern
export const cardBg    = '#0b1329'; // Latar belakang kartu/tabel semi-transparan
export const sidebarBg = '#0b1329';

// CSS class umum
export const cardCls = "rounded-3xl border border-slate-800/60 shadow-xl shadow-black/10 backdrop-blur-md overflow-hidden";

// Input field modern dengan rounding halus
export const inputCls =
    "w-full rounded-xl px-4 py-2.5 text-xs font-medium text-slate-200 placeholder-slate-600 " +
    "bg-slate-900/60 border border-slate-800 focus:outline-none focus:border-blue-500 " +
    "focus:ring-1 focus:ring-blue-500/20 transition-all duration-300";

// Status badge classes
export const statusBadge = {
    'Segera Pesan':    'bg-rose-500/10 text-rose-400 border border-rose-500/20 text-[10px] font-bold px-2.5 py-1 rounded-full uppercase tracking-wider',
    'Dalam Pemesanan': 'bg-blue-500/10 text-blue-400 border border-blue-500/20 text-[10px] font-bold px-2.5 py-1 rounded-full uppercase tracking-wider',
    'Waspada':         'bg-amber-500/10 text-amber-400 border border-amber-500/20 text-[10px] font-bold px-2.5 py-1 rounded-full uppercase tracking-wider',
    'Aman':            'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-[10px] font-bold px-2.5 py-1 rounded-full uppercase tracking-wider',
};

export const statusDot = {
    'Segera Pesan':    'bg-rose-400',
    'Dalam Pemesanan': 'bg-blue-400',
    'Waspada':         'bg-amber-400',
    'Aman':            'bg-emerald-400',
};

// Page header component helper
export function PageHeader({ title, subtitle, action }) {
    return (
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
            <div>
                <h2 className="text-white font-bold text-base tracking-wide leading-tight">{title}</h2>
                {subtitle && <p className="text-slate-500 text-xs mt-1 font-medium">{subtitle}</p>}
            </div>
            {action && <div className="flex-shrink-0">{action}</div>}
        </div>
    );
}

// Tombol premium dengan soft gradient & shadow
export function BtnPrimary({ children, onClick, href, color = 'blue', className = '' }) {
    const colors = {
        blue:    'bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 shadow-blue-500/20',
        emerald: 'bg-gradient-to-r from-emerald-600 to-green-600 hover:from-emerald-500 hover:to-green-500 shadow-emerald-500/20',
        rose:    'bg-gradient-to-r from-rose-600 to-red-600 hover:from-rose-500 hover:to-red-500 shadow-rose-500/20',
        amber:   'bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-400 hover:to-orange-400 shadow-amber-500/20',
    };
    const base = `inline-flex items-center gap-1.5 text-white px-4 py-2.5 rounded-xl text-xs font-bold transition-all duration-300 shadow-md ${colors[color] ?? colors.blue} hover:-translate-y-0.5 active:translate-y-0 ${className}`;

    if (href) {
        return <Link href={href} className={base}>{children}</Link>;
    }
    return <button onClick={onClick} className={base}>{children}</button>;
}
