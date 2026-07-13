import React, { useState } from 'react';
import { Head, Link } from '@inertiajs/react';
import { Menu, X, Phone, MapPin, Clock, Star, ShieldCheck, ChevronRight, MessageCircle, Navigation, Info } from 'lucide-react';
import { motion } from 'framer-motion';
import { Swiper, SwiperSlide } from 'swiper/react';
import { Autoplay, Pagination, EffectFade } from 'swiper/modules';
import 'swiper/css';
import 'swiper/css/pagination';
import 'swiper/css/effect-fade';

// Animation variants
const fadeInUp = {
    hidden: { opacity: 0, y: 40 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: "easeOut" } }
};

const staggerContainer = {
    hidden: { opacity: 0 },
    visible: {
        opacity: 1,
        transition: { staggerChildren: 0.1 }
    }
};

export default function Home({ services, testimonials, googlePhotos, googleRating, totalReviews, isGoogleData }) {
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    return (
        <div className="min-h-screen bg-slate-950 font-sans selection:bg-blue-500/30 text-slate-300">
            <Head title="Budi Variasi Mobil Ngawi | Aksesoris & Suku Cadang Terlengkap" />

            {/* Navbar */}
            <nav className="bg-slate-950/80 backdrop-blur-xl shadow-lg shadow-black/20 border-b border-white/5 sticky top-0 z-50 transition-all">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between h-20">
                        <div className="flex items-center">
                            <motion.h1 
                                initial={{ opacity: 0, x: -20 }}
                                animate={{ opacity: 1, x: 0 }}
                                className="text-2xl font-black text-white tracking-tight flex items-center"
                            >
                                <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-cyan-400 rounded-lg mr-2 flex items-center justify-center text-white text-lg shadow-lg shadow-blue-500/20">B</div>
                                Budi Variasi
                            </motion.h1>
                        </div>
                        
                        {/* Desktop Menu */}
                        <div className="hidden md:flex items-center space-x-8">
                            <a href="#services" className="text-slate-300 hover:text-white font-medium transition-colors">Layanan</a>
                            <a href="#gallery" className="text-slate-300 hover:text-white font-medium transition-colors">Galeri</a>
                            <a href="#testimonials" className="text-slate-300 hover:text-white font-medium transition-colors">Ulasan</a>
                            <a href="#location" className="text-slate-300 hover:text-white font-medium transition-colors">Lokasi</a>
                            <motion.a 
                                whileHover={{ scale: 1.05 }}
                                whileTap={{ scale: 0.95 }}
                                href="https://wa.me/6285856048737" target="_blank" rel="noreferrer" 
                                className="bg-gradient-to-r from-blue-600 to-cyan-500 text-white px-6 py-2.5 rounded-full font-medium shadow-lg shadow-blue-500/25 flex items-center border border-white/10"
                            >
                                <MessageCircle className="w-4 h-4 mr-2" />
                                Konsultasi Gratis
                            </motion.a>
                        </div>

                        {/* Mobile Menu Button */}
                        <div className="flex items-center md:hidden">
                            <button onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)} className="text-slate-300 hover:text-white focus:outline-none">
                                {isMobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
                            </button>
                        </div>
                    </div>
                </div>

                {/* Mobile Menu */}
                {isMobileMenuOpen && (
                    <motion.div 
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: 'auto' }}
                        className="md:hidden bg-slate-900 border-t border-white/5 px-4 pt-2 pb-6 space-y-2 shadow-2xl"
                    >
                        <a href="#services" onClick={() => setIsMobileMenuOpen(false)} className="block px-4 py-3 text-base font-medium text-slate-300 hover:bg-slate-800 hover:text-white rounded-xl">Layanan</a>
                        <a href="#gallery" onClick={() => setIsMobileMenuOpen(false)} className="block px-4 py-3 text-base font-medium text-slate-300 hover:bg-slate-800 hover:text-white rounded-xl">Galeri</a>
                        <a href="#testimonials" onClick={() => setIsMobileMenuOpen(false)} className="block px-4 py-3 text-base font-medium text-slate-300 hover:bg-slate-800 hover:text-white rounded-xl">Ulasan</a>
                        <a href="#location" onClick={() => setIsMobileMenuOpen(false)} className="block px-4 py-3 text-base font-medium text-slate-300 hover:bg-slate-800 hover:text-white rounded-xl">Lokasi</a>
                    </motion.div>
                )}
            </nav>

            {/* Hero Section */}
            <div className="relative bg-slate-950 overflow-hidden">
                <div className="absolute inset-0 z-0">
                    <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80')] bg-cover bg-center opacity-30 mix-blend-luminosity"></div>
                    <div className="absolute inset-0 bg-gradient-to-r from-slate-950 via-slate-950/90 to-transparent"></div>
                    <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-transparent to-slate-950/50"></div>
                </div>

                <div className="max-w-7xl mx-auto relative z-10">
                    <div className="pb-8 sm:pb-16 md:pb-20 lg:max-w-3xl lg:w-full lg:pb-28 xl:pb-32 px-4 sm:px-6 lg:px-8 pt-16 sm:pt-24 lg:pt-32">
                        <motion.main 
                            initial="hidden"
                            animate="visible"
                            variants={staggerContainer}
                            className="mx-auto max-w-7xl"
                        >
                            <div className="sm:text-center lg:text-left">
                                <motion.span variants={fadeInUp} className="inline-flex items-center py-1.5 px-4 rounded-full bg-blue-500/10 text-cyan-400 text-sm font-bold tracking-wide mb-6 border border-blue-500/20 shadow-[0_0_15px_rgba(56,189,248,0.15)] backdrop-blur-sm">
                                    <Star className="w-4 h-4 text-yellow-400 mr-2 fill-current" />
                                    Bengkel Variasi #1 di Ngawi
                                </motion.span>
                                <motion.h2 variants={fadeInUp} className="text-4xl tracking-tight font-extrabold text-white sm:text-5xl md:text-6xl leading-[1.1]">
                                    <span className="block xl:inline drop-shadow-md">Pusat Variasi &</span>{' '}
                                    <span className="block text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-blue-500 xl:inline drop-shadow-lg">
                                        Suku Cadang Mobil
                                    </span>
                                </motion.h2>
                                <motion.p variants={fadeInUp} className="mt-5 text-base text-slate-400 sm:mt-6 sm:text-lg sm:max-w-xl sm:mx-auto md:mt-8 md:text-xl lg:mx-0 leading-relaxed font-light">
                                    Meningkatkan kenyamanan dan tampilan mobil Anda dengan produk original berkualitas, harga bersaing, dan pemasangan profesional bergaransi.
                                </motion.p>
                                <motion.div variants={fadeInUp} className="mt-8 sm:mt-10 sm:flex sm:justify-center lg:justify-start gap-4">
                                    <div className="rounded-full shadow-[0_0_20px_rgba(34,197,94,0.3)]">
                                        <a href="https://wa.me/6285856048737" target="_blank" rel="noreferrer" className="w-full flex items-center justify-center px-8 py-4 border border-transparent text-base font-semibold rounded-full text-white bg-gradient-to-r from-emerald-500 to-green-600 hover:from-emerald-400 hover:to-green-500 transition-all duration-300">
                                            <MessageCircle className="w-5 h-5 mr-2" />
                                            Hubungi via WhatsApp
                                        </a>
                                    </div>
                                    <div className="mt-4 sm:mt-0">
                                        <a href="https://maps.google.com/?q=Jl.+Basuki+Rahmat+No.93+Ruko+No.+1,+Ngawi" target="_blank" rel="noreferrer" className="w-full flex items-center justify-center px-8 py-4 border border-white/20 text-base font-semibold rounded-full text-white bg-white/5 hover:bg-white/10 backdrop-blur-md transition-all duration-300">
                                            <Navigation className="w-5 h-5 mr-2 text-cyan-400" />
                                            Petunjuk Arah
                                        </a>
                                    </div>
                                </motion.div>
                            </div>
                        </motion.main>
                    </div>
                </div>
            </div>

            {/* Social Proof Banner */}
            <div className="bg-slate-900/50 backdrop-blur-md py-6 border-y border-white/5 relative z-20">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row items-center justify-between">
                    <div className="flex items-center mb-4 md:mb-0">
                        <div className="flex -space-x-3 mr-4">
                            {[1, 2, 3, 4].map((i) => (
                                <img key={i} className="w-10 h-10 rounded-full border-2 border-slate-900" src={`https://i.pravatar.cc/100?img=${i+10}`} alt="Customer" />
                            ))}
                        </div>
                        <div>
                            <div className="flex items-center space-x-2">
                                <div className="flex text-yellow-400">
                                    {[...Array(5)].map((_, i) => (
                                        <Star key={i} className={`w-5 h-5 ${i < Math.floor(googleRating) ? 'fill-current' : ''}`} />
                                    ))}
                                </div>
                                <span className="text-white font-bold">{googleRating}/5.0</span>
                            </div>
                            <p className="text-slate-400 text-sm mt-0.5">Dari {totalReviews} Ulasan Google Maps</p>
                        </div>
                    </div>
                    <div className="flex items-center space-x-6 text-cyan-100 text-sm font-medium">
                        <div className="flex items-center bg-cyan-950/30 px-3 py-1.5 rounded-full border border-cyan-500/20">
                            <ShieldCheck className="w-5 h-5 mr-1.5 text-cyan-400" />
                            Produk Original
                        </div>
                        <div className="hidden sm:flex items-center bg-cyan-950/30 px-3 py-1.5 rounded-full border border-cyan-500/20">
                            <ShieldCheck className="w-5 h-5 mr-1.5 text-cyan-400" />
                            Teknisi Ahli
                        </div>
                        <div className="hidden lg:flex items-center bg-cyan-950/30 px-3 py-1.5 rounded-full border border-cyan-500/20">
                            <ShieldCheck className="w-5 h-5 mr-1.5 text-cyan-400" />
                            Garansi Pemasangan
                        </div>
                    </div>
                </div>
            </div>

            {/* Interactive Photo Gallery from Google Maps */}
            {googlePhotos && googlePhotos.length > 0 && (
                <div id="gallery" className="py-24 bg-slate-950 overflow-hidden relative">
                    <div className="absolute top-0 right-0 w-1/2 h-96 bg-cyan-900/10 blur-[100px] rounded-full pointer-events-none"></div>
                    
                    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
                        <motion.div 
                            initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeInUp}
                            className="flex flex-col md:flex-row justify-between items-end mb-12"
                        >
                            <div>
                                <h2 className="text-3xl font-extrabold text-white tracking-tight">Galeri Pekerjaan Kami</h2>
                                <p className="mt-3 text-lg text-slate-400 font-light">Melihat langsung hasil pemasangan dan suasana bengkel dari Google Maps.</p>
                            </div>
                            {isGoogleData && (
                                <div className="mt-6 md:mt-0 flex items-center text-sm font-medium text-slate-300 bg-white/5 border border-white/10 px-4 py-2 rounded-full backdrop-blur-md shadow-lg">
                                    <Info className="w-4 h-4 mr-2 text-cyan-400" /> Live dari Google
                                </div>
                            )}
                        </motion.div>

                        <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeInUp}>
                            <Swiper
                                modules={[Autoplay, Pagination]}
                                spaceBetween={24}
                                slidesPerView={1}
                                breakpoints={{
                                    640: { slidesPerView: 2 },
                                    1024: { slidesPerView: 3 },
                                }}
                                autoplay={{ delay: 3000, disableOnInteraction: false }}
                                pagination={{ clickable: true, dynamicBullets: true }}
                                className="pb-14"
                            >
                                {googlePhotos.map((photo, index) => (
                                    <SwiperSlide key={index}>
                                        <div className="relative h-80 rounded-3xl overflow-hidden group shadow-[0_8px_30px_rgba(0,0,0,0.5)] border border-white/5">
                                            <img src={photo} alt="Galeri Budi Variasi" className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" />
                                            <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/20 to-transparent opacity-60 group-hover:opacity-40 transition-opacity duration-500"></div>
                                        </div>
                                    </SwiperSlide>
                                ))}
                            </Swiper>
                        </motion.div>
                    </div>
                </div>
            )}

            {/* Services Grid */}
            <div id="services" className="py-24 bg-slate-900 relative">
                <div className="absolute top-1/2 left-0 w-96 h-96 bg-blue-900/10 blur-[100px] rounded-full pointer-events-none -translate-y-1/2"></div>
                
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
                    <motion.div 
                        initial="hidden" whileInView="visible" viewport={{ once: true, margin: "-100px" }} variants={fadeInUp}
                        className="text-center mb-16"
                    >
                        <h2 className="text-3xl font-extrabold text-white sm:text-4xl tracking-tight">Layanan & Produk Unggulan</h2>
                        <div className="w-24 h-1.5 bg-gradient-to-r from-cyan-400 to-blue-500 rounded-full mx-auto mt-6 mb-6 shadow-[0_0_10px_rgba(56,189,248,0.5)]"></div>
                        <p className="text-xl text-slate-400 max-w-2xl mx-auto font-light">Kami menyediakan berbagai kebutuhan untuk membuat mobil Anda tampil lebih baik dan nyaman dikendarai.</p>
                    </motion.div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                        {services && services.length > 0 ? (
                            services.map((service, index) => (
                                <motion.div 
                                    key={service.id} 
                                    initial={{ opacity: 0, y: 50 }}
                                    whileInView={{ opacity: 1, y: 0 }}
                                    viewport={{ once: true }}
                                    transition={{ duration: 0.5, delay: index * 0.1 }}
                                    className="bg-slate-800/50 backdrop-blur-sm rounded-3xl shadow-xl hover:shadow-2xl hover:shadow-cyan-900/20 transition-all duration-300 overflow-hidden group border border-white/5 hover:border-cyan-500/30"
                                >
                                    <div className="h-60 bg-slate-800 overflow-hidden relative">
                                        {service.image ? (
                                            <img src={service.image.includes('1600329971981') ? 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80' : service.image} alt={service.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700 opacity-80 group-hover:opacity-100" />
                                        ) : (
                                            <div className="w-full h-full flex items-center justify-center text-slate-600 bg-slate-800/80">
                                                <ShieldCheck className="w-20 h-20 opacity-50" />
                                            </div>
                                        )}
                                        <div className="absolute inset-0 bg-gradient-to-t from-slate-900 to-transparent opacity-80"></div>
                                        <div className="absolute bottom-4 left-4 right-4 flex justify-between items-end">
                                            <h3 className="text-xl font-bold text-white drop-shadow-md">{service.title}</h3>
                                        </div>
                                    </div>
                                    <div className="p-8">
                                        <p className="text-slate-400 mb-8 line-clamp-3 leading-relaxed font-light">{service.description}</p>
                                        <a href="https://wa.me/6285856048737" className="inline-flex items-center text-cyan-400 font-semibold hover:text-cyan-300 transition-colors group/link w-full justify-center bg-cyan-950/30 hover:bg-cyan-900/50 py-3 rounded-xl border border-cyan-900/50">
                                            Konsultasi Sekarang 
                                            <ChevronRight className="w-4 h-4 ml-1 transform group-hover/link:translate-x-1 transition-transform" />
                                        </a>
                                    </div>
                                </motion.div>
                            ))
                        ) : (
                            <div className="col-span-full text-center text-slate-500 py-10 bg-slate-800/30 rounded-3xl border border-dashed border-slate-700">
                                Belum ada data layanan saat ini.
                            </div>
                        )}
                    </div>
                </div>
            </div>

            {/* Interactive Live Reviews */}
            <div id="testimonials" className="py-24 bg-slate-950 overflow-hidden relative">
                {/* Background Decoration */}
                <div className="absolute top-0 left-0 w-full h-full overflow-hidden z-0 pointer-events-none">
                    <div className="absolute top-1/4 right-1/4 w-96 h-96 rounded-full bg-cyan-900/10 blur-[120px]"></div>
                    <div className="absolute bottom-1/4 left-1/4 w-96 h-96 rounded-full bg-blue-900/10 blur-[120px]"></div>
                </div>

                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
                    <motion.div 
                        initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeInUp}
                        className="text-center mb-16"
                    >
                        <h2 className="text-3xl font-extrabold text-white sm:text-4xl tracking-tight">Apa Kata Pelanggan Kami</h2>
                        <p className="mt-4 text-xl text-slate-400 max-w-2xl mx-auto font-light">
                            Kepuasan pelanggan adalah prioritas utama kami.
                        </p>
                    </motion.div>

                    <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeInUp}>
                        <Swiper
                            modules={[Autoplay, Pagination]}
                            spaceBetween={30}
                            slidesPerView={1}
                            breakpoints={{
                                768: { slidesPerView: 2 },
                                1024: { slidesPerView: 3 },
                            }}
                            autoplay={{ delay: 4000, disableOnInteraction: true }}
                            pagination={{ clickable: true }}
                            className="pb-16"
                        >
                            {testimonials && testimonials.length > 0 ? (
                                testimonials.map((testi, index) => (
                                    <SwiperSlide key={index}>
                                        <div className="bg-slate-900/80 backdrop-blur-xl rounded-3xl p-8 shadow-[0_8px_30px_rgba(0,0,0,0.3)] border border-white/5 h-full flex flex-col hover:border-cyan-500/20 transition-colors duration-300 relative overflow-hidden">
                                            <div className="absolute top-0 right-0 w-32 h-32 bg-cyan-500/5 blur-[50px] rounded-full"></div>
                                            
                                            <div className="flex justify-between items-start mb-6 relative z-10">
                                                <div className="flex items-center">
                                                    {testi.profile_photo_url ? (
                                                        <img src={testi.profile_photo_url} alt={testi.name} className="w-12 h-12 rounded-full mr-4 border-2 border-slate-800" />
                                                    ) : (
                                                        <div className="w-12 h-12 rounded-full bg-cyan-900/50 text-cyan-400 flex items-center justify-center font-bold text-xl mr-4 border border-cyan-800/50">
                                                            {testi.name.charAt(0)}
                                                        </div>
                                                    )}
                                                    <div>
                                                        <div className="font-bold text-white">{testi.name}</div>
                                                        <div className="text-sm text-slate-400 font-light">{testi.relative_time_description}</div>
                                                    </div>
                                                </div>
                                                {testi.source === 'Google Maps' && (
                                                    <svg viewBox="0 0 24 24" className="w-6 h-6 text-cyan-400 drop-shadow-[0_0_8px_rgba(34,211,238,0.5)]" fill="currentColor">
                                                        <path d="M21.35,11.1H12.18V13.83H18.69C18.36,17.64 15.19,19.27 12.19,19.27C8.36,19.27 5,16.25 5,12C5,7.9 8.2,4.73 12.2,4.73C15.29,4.73 17.1,6.7 17.1,6.7L19,4.72C19,4.72 16.56,2 12.1,2C6.42,2 2.03,6.8 2.03,12C2.03,17.05 6.16,22 12.25,22C17.6,22 21.5,18.33 21.5,12.91C21.5,11.76 21.35,11.1 21.35,11.1V11.1Z" />
                                                    </svg>
                                                )}
                                            </div>
                                            <div className="flex items-center mb-5 text-yellow-400 drop-shadow-sm relative z-10">
                                                {[...Array(5)].map((_, i) => (
                                                    <Star key={i} className={`w-4 h-4 ${i < testi.rating ? 'fill-current' : 'text-slate-700'}`} />
                                                ))}
                                            </div>
                                            <p className="text-slate-300 font-light leading-relaxed flex-grow relative z-10">"{testi.review_text}"</p>
                                        </div>
                                    </SwiperSlide>
                                ))
                            ) : (
                                <SwiperSlide>
                                    <div className="text-center text-slate-500 p-8 bg-slate-900/50 rounded-3xl border border-white/5">Belum ada ulasan saat ini.</div>
                                </SwiperSlide>
                            )}
                        </Swiper>
                    </motion.div>
                </div>
            </div>

            {/* Location & Contact Info */}
            <div id="location" className="relative bg-slate-900 py-24 overflow-hidden border-t border-white/5">
                <div className="absolute inset-0 bg-gradient-to-b from-slate-900 to-slate-950"></div>
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
                        <motion.div 
                            initial="hidden" whileInView="visible" viewport={{ once: true }} variants={staggerContainer}
                        >
                            <motion.h2 variants={fadeInUp} className="text-3xl font-extrabold text-white sm:text-5xl mb-6 tracking-tight">Kunjungi Bengkel Kami</motion.h2>
                            <motion.p variants={fadeInUp} className="text-slate-400 mb-10 text-lg font-light">Dapatkan pelayanan prima dan konsultasi langsung dengan ahlinya.</motion.p>
                            
                            <div className="space-y-8">
                                <motion.div variants={fadeInUp} className="flex items-start group">
                                    <div className="flex-shrink-0 bg-slate-800/80 backdrop-blur-md rounded-2xl p-4 border border-white/5 group-hover:border-cyan-500/30 transition-colors shadow-lg">
                                        <MapPin className="w-8 h-8 text-cyan-400" />
                                    </div>
                                    <div className="ml-5">
                                        <h3 className="text-xl font-semibold text-white mb-2">Alamat Lengkap</h3>
                                        <p className="text-slate-400 leading-relaxed font-light">Jl. Basuki Rahmat No.93 Ruko No. 1<br />Besaran, Karangasri, Kec. Ngawi<br />Kabupaten Ngawi, Jawa Timur 63217</p>
                                    </div>
                                </motion.div>

                                <motion.div variants={fadeInUp} className="flex items-start group">
                                    <div className="flex-shrink-0 bg-slate-800/80 backdrop-blur-md rounded-2xl p-4 border border-white/5 group-hover:border-cyan-500/30 transition-colors shadow-lg">
                                        <Clock className="w-8 h-8 text-cyan-400" />
                                    </div>
                                    <div className="ml-5">
                                        <h3 className="text-xl font-semibold text-white mb-2">Jam Operasional</h3>
                                        <div className="text-slate-400 space-y-2 font-light">
                                            <p className="flex justify-between w-64 border-b border-white/5 pb-2"><span>Senin - Sabtu:</span> <span className="font-medium text-white">08.00 - 16.30</span></p>
                                            <p className="flex justify-between w-64 pt-1"><span>Minggu:</span> <span className="text-red-400 font-semibold drop-shadow-sm">Tutup</span></p>
                                        </div>
                                    </div>
                                </motion.div>
                            </div>
                        </motion.div>

                        <motion.div 
                            initial={{ opacity: 0, scale: 0.95 }} whileInView={{ opacity: 1, scale: 1 }} viewport={{ once: true }} transition={{ duration: 0.8, ease: "easeOut" }}
                            className="bg-slate-800 rounded-[2.5rem] overflow-hidden h-[500px] shadow-[0_20px_50px_rgba(0,0,0,0.5)] ring-1 ring-white/10 relative group"
                        >
                            <iframe 
                                title="Map Budi Variasi Mobil"
                                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d15814.372561956554!2d111.4496004!3d-7.4075849!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2e79e7ddbb80be95%3A0x7a2aa36a790da07f!2sBudi%20Variasi%20Mobil!5e0!3m2!1sid!2sid!4v1715610000000!5m2!1sid!2sid" 
                                width="100%" 
                                height="100%" 
                                style={{ border: 0 }} 
                                allowFullScreen="" 
                                loading="lazy"
                                className="grayscale-[50%] contrast-125 hover:grayscale-0 transition-all duration-1000 opacity-90 hover:opacity-100"
                            ></iframe>
                            <div className="absolute bottom-6 left-1/2 transform -translate-x-1/2 bg-slate-900/90 backdrop-blur-md px-6 py-3 rounded-full text-white font-bold text-sm shadow-2xl pointer-events-none opacity-100 group-hover:opacity-0 transition-opacity border border-white/10">
                                Ketuk untuk interaksi Peta
                            </div>
                        </motion.div>
                    </div>
                </div>
            </div>

            {/* Footer */}
            <footer className="bg-[#020617] py-12 border-t border-white/5 relative overflow-hidden">
                <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-full max-w-lg h-px bg-gradient-to-r from-transparent via-cyan-500/50 to-transparent"></div>
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row justify-between items-center text-center md:text-left relative z-10">
                    <div className="mb-4 md:mb-0">
                        <span className="text-2xl font-black text-white tracking-tight flex items-center justify-center md:justify-start">
                            <div className="w-6 h-6 bg-gradient-to-br from-blue-500 to-cyan-400 rounded mr-2 flex items-center justify-center text-white text-xs shadow-lg">B</div>
                            Budi Variasi
                        </span>
                        <p className="text-slate-500 text-sm mt-2 font-light">Pusat Variasi & Suku Cadang Terlengkap di Ngawi.</p>
                    </div>
                    <div className="flex items-center gap-4">
                        <p className="text-slate-600 text-sm font-light">&copy; {new Date().getFullYear()} Budi Variasi Mobil. Hak Cipta Dilindungi.</p>
                        <Link
                            href="/admin/login"
                            className="flex items-center gap-1.5 text-slate-500 hover:text-white text-xs px-3 py-1.5 rounded-lg border border-white/10 hover:border-white/20 hover:bg-white/5 transition-all duration-200"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" className="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            Admin
                        </Link>
                    </div>
                </div>
            </footer>

            {/* Floating WhatsApp Button */}
            <motion.a 
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                transition={{ type: "spring", stiffness: 260, damping: 20 }}
                href="https://wa.me/6285856048737" 
                target="_blank" 
                rel="noreferrer"
                className="fixed bottom-6 right-6 bg-gradient-to-br from-green-400 to-green-600 text-white p-4 rounded-full shadow-[0_10px_30px_rgba(34,197,94,0.4)] z-50 flex items-center justify-center group border border-white/20"
                aria-label="Hubungi via WhatsApp"
            >
                <MessageCircle className="w-7 h-7 drop-shadow-md" />
                <span className="absolute right-full mr-4 bg-slate-900/90 backdrop-blur border border-white/10 text-white px-4 py-2.5 rounded-2xl shadow-2xl font-semibold text-sm whitespace-nowrap opacity-0 group-hover:opacity-100 transform translate-x-4 group-hover:translate-x-0 transition-all duration-300 pointer-events-none">
                    Tanya Harga & Stok? Chat Kami
                </span>
            </motion.a>
        </div>
    );
}
