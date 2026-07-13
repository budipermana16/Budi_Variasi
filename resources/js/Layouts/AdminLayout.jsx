import React, { useState } from 'react';
import { Link, router, usePage } from '@inertiajs/react';
import {
    LayoutDashboard, Package, Truck, ShoppingCart,
    PackagePlus, BarChart3, LogOut, Menu, Bell,
    AlertTriangle, TrendingUp, Settings2, Wrench,
    MessageSquare, Users, User, ChevronRight
} from 'lucide-react';

const menuGroups = [
    {
        title: 'Operasional Toko',
        roles: ['owner', 'admin_gudang'],
        items: [
            { label: 'Dashboard', href: '/admin/dashboard', icon: LayoutDashboard, roles: ['owner', 'admin_gudang'] },
            { label: 'Manajemen Produk', href: '/admin/products', icon: Package, roles: ['owner', 'admin_gudang'] },
            { label: 'Data Supplier', href: '/admin/suppliers', icon: Truck, roles: ['owner'] },
            { label: 'Catat Penjualan', href: '/admin/sales', icon: ShoppingCart, roles: ['owner', 'admin_gudang'] },
            { label: 'Barang Masuk (PO)', href: '/admin/purchases', icon: PackagePlus, roles: ['owner', 'admin_gudang'] },
        ]
    },
    {
        title: 'Analisis Stok (ROP)',
        roles: ['owner'],
        items: [
            { label: 'Laporan Perhitungan ROP', href: '/admin/inventory/report', icon: BarChart3, roles: ['owner'] },
            { label: 'Konfigurasi Safety Stock', href: '/admin/inventory/settings', icon: Settings2, roles: ['owner'] },
        ]
    },
    {
        title: 'Manajemen Website',
        roles: ['owner', 'admin_gudang'],
        items: [
            { label: 'Kelola Layanan Jasa', href: '/admin/services', icon: Wrench, roles: ['owner', 'admin_gudang'] },
            { label: 'Testimoni Pelanggan', href: '/admin/testimonials', icon: MessageSquare, roles: ['owner'] },
        ]
    },
    {
        title: 'Sistem & Akun',
        roles: ['owner', 'admin_gudang'],
        items: [
            { label: 'Kelola Hak Akses (User)', href: '/admin/users', icon: Users, roles: ['owner'] },
            { label: 'Profil Saya', href: '/admin/profile', icon: User, roles: ['owner', 'admin_gudang'] },
        ]
    }
];

export default function AdminLayout({ children, user, alertCount = 0, title = '' }) {
    const { auth } = usePage().props;
    const currentUser = user || auth?.user;
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const currentPath = typeof window !== 'undefined' ? window.location.pathname : '';

    const handleLogout = () => {
        router.post('/admin/logout');
    };

    const NavLink = ({ item }) => {
        const Icon = item.icon;
        const isActive = currentPath === item.href ||
            (item.href !== '/admin/dashboard' && currentPath.startsWith(item.href));

        return (
            <Link
                href={item.href}
                onClick={() => setSidebarOpen(false)}
                className={`group flex items-center justify-between px-3 py-2 rounded-xl text-xs font-semibold transition-all duration-300 ${
                    isActive
                        ? 'bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-md shadow-blue-500/20'
                        : 'text-slate-400 hover:text-slate-100 hover:bg-slate-800/50'
                }`}
            >
                <div className="flex items-center gap-2.5">
                    <Icon className={`w-4 h-4 flex-shrink-0 ${isActive ? 'text-white' : 'text-slate-400 group-hover:text-blue-400 transition-colors'}`} />
                    <span>{item.label}</span>
                </div>
                {isActive && <ChevronRight className="w-3.5 h-3.5 text-white/70" />}
            </Link>
        );
    };

    const SidebarContent = () => (
        <div className="flex flex-col h-full bg-[#0b1329] border-r border-slate-800/60">
            {/* Brand/Header */}
            <div className="px-5 py-4 border-b border-slate-800/60 flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 bg-gradient-to-tr from-blue-500 to-indigo-600 rounded-lg flex items-center justify-center shadow-lg shadow-blue-500/25 flex-shrink-0">
                        <TrendingUp className="w-4 h-4 text-white" />
                    </div>
                    <div>
                        <p className="text-slate-100 font-bold text-xs tracking-wide">BUDI VARIASI</p>
                        <p className="text-blue-400/80 text-[10px] font-medium tracking-wider">SYSTEM ROP</p>
                    </div>
                </div>
            </div>

            {/* Warning Alert stok kritis di Sidebar */}
            {alertCount > 0 && currentUser?.role === 'owner' && (
                <div className="mx-4 mt-3">
                    <Link
                        href="/admin/inventory/report"
                        className="flex items-center gap-2.5 px-3 py-2 bg-rose-500/5 border border-rose-500/10 rounded-xl hover:bg-rose-500/10 transition-colors"
                    >
                        <AlertTriangle className="w-4 h-4 text-rose-400 flex-shrink-0 animate-pulse" />
                        <div className="min-w-0 flex-1">
                            <p className="text-rose-300 text-[10px] font-bold truncate">{alertCount} Barang Kritis</p>
                            <p className="text-slate-500 text-[9px] truncate">Stok dibawah ROP</p>
                        </div>
                        <span className="w-4 h-4 bg-rose-500 text-white text-[9px] font-bold rounded-full flex items-center justify-center">
                            {alertCount}
                        </span>
                    </Link>
                </div>
            )}

            {/* Navigation Menu */}
            <nav className="flex-1 overflow-y-auto px-3 py-4 space-y-4">
                {menuGroups
                    .filter(group => group.roles.includes(currentUser?.role))
                    .map((group, idx) => (
                        <div key={idx} className="space-y-1">
                            <p className="text-[10px] font-bold text-slate-500/80 uppercase tracking-widest px-3 mb-1">
                                {group.title}
                            </p>
                            <div className="space-y-0.5">
                                {group.items
                                    .filter(item => !item.roles || item.roles.includes(currentUser?.role))
                                    .map(item => <NavLink key={item.href} item={item} />)
                                }
                            </div>
                        </div>
                    ))}
            </nav>

            {/* User Profile & Logout */}
            <div className="p-3 border-t border-slate-800/60 bg-slate-900/30">
                <div className="flex items-center gap-2.5 px-3 py-2 bg-slate-900/50 border border-slate-800/40 rounded-xl mb-2">
                    <div className="w-7 h-7 rounded-lg bg-gradient-to-tr from-blue-500 to-indigo-600 flex items-center justify-center text-white text-xs font-bold shadow flex-shrink-0">
                        {currentUser?.name?.charAt(0)?.toUpperCase() ?? 'U'}
                    </div>
                    <div className="min-w-0 flex-1">
                        <p className="text-slate-200 text-xs font-bold truncate leading-none mb-1">{currentUser?.name ?? 'Pengguna'}</p>
                        <span className="inline-block text-[9px] font-semibold text-blue-400 bg-blue-500/10 px-1.5 py-0.5 rounded uppercase tracking-wider scale-95 origin-left">
                            {(currentUser?.role ?? '').replace('_', ' ')}
                        </span>
                    </div>
                </div>
                <button
                    onClick={handleLogout}
                    className="w-full flex items-center gap-2 px-3 py-2 text-slate-500 hover:text-rose-400 hover:bg-rose-500/5 rounded-xl transition-all text-xs font-semibold"
                >
                    <LogOut className="w-3.5 h-3.5" />
                    Keluar Sistem
                </button>
            </div>
        </div>
    );

    return (
        <div className="min-h-screen text-slate-300 flex bg-[#080d1a]">
            {/* Sidebar Desktop */}
            <aside className="hidden lg:flex flex-col w-56 fixed top-0 left-0 h-full z-30">
                <SidebarContent />
            </aside>

            {/* Sidebar Mobile */}
            {sidebarOpen && (
                <div className="fixed inset-0 z-40 lg:hidden">
                    <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setSidebarOpen(false)} />
                    <aside className="absolute left-0 top-0 h-full w-56 z-50">
                        <SidebarContent />
                    </aside>
                </div>
            )}

            {/* Main Content Area */}
            <div className="flex-1 lg:ml-56 flex flex-col min-h-screen">
                {/* Header/Topbar */}
                <header className="sticky top-0 z-20 h-14 px-6 flex items-center justify-between bg-[#0b1329]/80 backdrop-blur-md border-b border-slate-800/60">
                    <div className="flex items-center gap-3">
                        <button
                            onClick={() => setSidebarOpen(true)}
                            className="lg:hidden p-2 rounded-xl text-slate-400 hover:text-slate-100 hover:bg-slate-800/50 transition-all"
                        >
                            <Menu className="w-4 h-4" />
                        </button>
                        {title && (
                            <h1 className="text-slate-100 font-bold text-sm tracking-wide">{title}</h1>
                        )}
                    </div>

                    <div className="flex items-center gap-4">
                        {alertCount > 0 && currentUser?.role === 'owner' && (
                            <Link
                                href="/admin/inventory/report"
                                className="relative p-2 rounded-xl text-slate-400 hover:text-rose-400 hover:bg-slate-800/50 transition-all"
                            >
                                <Bell className="w-4 h-4" />
                                <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-rose-500 rounded-full ring-2 ring-[#0b1329]" />
                            </Link>
                        )}
                        <Link
                            href="/"
                            target="_blank"
                            className="hidden sm:inline-flex items-center gap-1.5 text-[11px] font-semibold text-slate-400 hover:text-blue-400 px-3 py-1.5 bg-slate-900/60 border border-slate-800/80 rounded-xl hover:bg-slate-800 transition-all"
                        >
                            Lihat Landing Page ↗
                        </Link>
                    </div>
                </header>

                {/* Main Content */}
                <main className="flex-1 p-6">
                    {children}
                </main>

                {/* Footer */}
                <footer className="text-center text-slate-600 text-[10px] py-4 border-t border-slate-900 bg-slate-950/20">
                    © {new Date().getFullYear()} Budi Variasi Mobil — Ngawi. Aplikasi Peramalan & Inventory Control.
                </footer>
            </div>
        </div>
    );
}
