import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import '../../../core/constants/api_constants.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class JadwalIbadahScreen extends StatefulWidget {
  const JadwalIbadahScreen({super.key});

  @override
  State<JadwalIbadahScreen> createState() => _JadwalIbadahScreenState();
}

class _JadwalIbadahScreenState extends State<JadwalIbadahScreen> {
  // Theme colors consistent with the app
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF7F4FB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF85879A);

  // Categories exactly as defined in React
  final List<String> kategoriOptions = [
    "Semua Kegiatan",
    "Ibadah Raya Minggu",
    "Ibadah Sekolah Minggu",
    "Ibadah Pemuda & Remaja",
    "Ibadah Wanita (Pelwap)",
    "Doa Malam Jemaat"
  ];

  String selectedCategory = "Semua Kegiatan";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<EventProvider>(context, listen: false).fetchPublicEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.jadwalIbadah),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: navy),
        title: const Text(
          'Jadwal & Kegiatan',
          style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          // Filter Logic matching React's useMemo
          final filteredWorship = provider.worshipSchedules.where((item) {
            final matchKat = selectedCategory == "Semua Kegiatan" || item.title == selectedCategory;

            final q = searchQuery.toLowerCase();
            final matchCari = item.day.toLowerCase().contains(q) ||
                item.title.toLowerCase().contains(q) ||
                item.location.toLowerCase().contains(q);

            return matchKat && matchCari;
          }).toList();

          return RefreshIndicator(
            onRefresh: () => provider.fetchPublicEvents(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // ══ JUDUL HALAMAN (Matching React Header) ══
                  _buildHeader(),

                  // ══ BANNER IMAGE (Matching React) ══
                  _buildBanner(),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: Color(0xFFCBD5E1), height: 48), // border-slate-300
                  ),

                  // ══ JADWAL IBADAH RUTIN SECTION ══
                  const SizedBox(height: 32),
                  const Text(
                    "Jadwal Ibadah Rutin",
                    style: TextStyle(color: navy, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Filters (Dropdown & Search)
                  _buildFilters(),

                  // Worship Table/List
                  if (provider.isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: navy)))
                  else if (filteredWorship.isEmpty)
                    _buildEmptyState("Tidak ada jadwal ibadah yang ditemukan.")
                  else
                    _buildWorshipTable(filteredWorship),

                  // ══ KEGIATAN KHUSUS / EVENT SECTION ══
                  const SizedBox(height: 80),
                  const Text(
                    "KEGIATAN KHUSUS / EVENT",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 40),

                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator(color: navy))
                  else if (provider.activities.isEmpty)
                    _buildEmptyState("Tidak ada event khusus dalam waktu dekat.")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: provider.activities.length,
                      itemBuilder: (context, index) => _buildEventCard(provider.activities[index]),
                    ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: -1),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
      child: Column(
        children: [
          const Text(
            'Jadwal Ibadah & Kegiatan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: navy,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Informasi Jadwal Ibadah Rutin dan Kegiatan Gereja',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          image: const DecorationImage(
            image: NetworkImage("https://images.unsplash.com/photo-1438232992991-995b7058bbb3?q=80&w=1440&auto=format&fit=crop"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Custom Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF94A3B8)), // border-slate-400
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                onChanged: (String? val) {
                  if (val != null) setState(() => selectedCategory = val);
                },
                items: kategoriOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Search Field
          TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Cari Hari/Tempat...",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF94A3B8))),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: navy)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorshipTable(List<WorshipScheduleModel> schedules) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF9F9F9)),
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('HARI', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('KATEGORI IBADAH', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('WAKTU', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('TEMPAT', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: schedules.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item.day, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                  DataCell(Text(item.title, style: const TextStyle(color: navy, fontWeight: FontWeight.w600))),
                  DataCell(Text("${item.time} WIB", style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500))),
                  DataCell(Text(item.location, style: const TextStyle(color: Color(0xFF334155)))),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(ActivityModel item) {
    String formattedDate = "-";
    try {
      final date = DateTime.parse(item.date);
      formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      formattedDate = item.date;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  item.image != null && item.image!.isNotEmpty
                      ? (item.image!.startsWith('http') ? item.image! : "http://10.220.181.201:8003/storage/${item.image}")
                      : "https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey.shade200),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: redAccent, borderRadius: BorderRadius.circular(20)),
                  child: const Text('EVENT KHUSUS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: navy, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF4B5563), fontSize: 16),
                    children: [
                      const TextSpan(text: 'Tanggal', style: TextStyle(fontWeight: FontWeight.bold, color: redAccent)),
                      TextSpan(text: ' : $formattedDate'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "\"${item.description}\"",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, fontStyle: FontStyle.italic, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: () => _showEventDetail(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Lihat Detail', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetail(ActivityModel item) {
    String formattedDateFull = "-";
    try {
      final date = DateTime.parse(item.date);
      formattedDateFull = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      formattedDateFull = item.date;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        item.image != null && item.image!.isNotEmpty
                            ? (item.image!.startsWith('http') ? item.image! : "http://10.220.181.201:8003/storage/${item.image}")
                            : "https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800",
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.3),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: navy.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Text('DETAIL EVENT', style: TextStyle(color: navy, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Text(item.title, style: const TextStyle(color: navy, fontSize: 28, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text('📅 $formattedDateFull', style: const TextStyle(color: redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(color: Color(0xFFE2E8F0)),
                      ),
                      Text(
                        item.description,
                        style: const TextStyle(color: Color(0xFF374151), fontSize: 16, height: 1.8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Text(
          message,
          style: const TextStyle(color: redAccent, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
