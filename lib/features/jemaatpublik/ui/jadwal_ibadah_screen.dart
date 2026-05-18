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
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

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
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: navy.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_rounded, color: navy, size: 22),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: const Text(
          'Jadwal & Kegiatan',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
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
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Filter Jadwal', 'Cari jadwal ibadah rutin'),
                  const SizedBox(height: 16),
                  _buildFilters(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Jadwal Ibadah Rutin', 'Mari bersekutu bersama kami'),
                  const SizedBox(height: 16),
                  if (provider.isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: navy)))
                  else if (filteredWorship.isEmpty)
                    _buildEmptyState("Tidak ada jadwal ibadah yang ditemukan.")
                  else
                    _buildModernTable(filteredWorship),
                  const SizedBox(height: 40),
                  _buildSectionHeader('Event Khusus', 'Kegiatan mendatang di gereja'),
                  const SizedBox(height: 16),
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator(color: navy))
                  else if (provider.activities.isEmpty)
                    _buildEmptyState("Tidak ada event khusus dalam waktu dekat.")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.activities.length,
                      itemBuilder: (context, index) => _buildEventCard(provider.activities[index]),
                    ),
                  const SizedBox(height: 40),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'IBADAH & KEGIATAN',
            style: TextStyle(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Jadwal Persekutuan\nJemaat Sibulele',
          style: TextStyle(
            color: navy,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textGrey),
              onChanged: (String? val) {
                if (val != null) setState(() => selectedCategory = val);
              },
              items: kategoriOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (val) => setState(() => searchQuery = val),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Cari hari atau lokasi...",
            prefixIcon: const Icon(Icons.search_rounded, color: textGrey, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: navy, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTable(List<WorshipScheduleModel> schedules) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: navy.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('HARI / WAKTU', style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5))),
                Expanded(flex: 3, child: Text('IBADAH', style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5))),
              ],
            ),
          ),
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedules.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withOpacity(0.05)),
            itemBuilder: (context, index) {
              final item = schedules[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.day, style: const TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: navy.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${item.time} WIB",
                              style: const TextStyle(color: navy, fontSize: 11, fontWeight: FontWeight.w700)
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 14)
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 12, color: gold),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.location,
                                  style: const TextStyle(color: textGrey, fontSize: 12, fontWeight: FontWeight.w500)
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
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

    String imageUrl = ApiConstants.getImageUrl(item.image);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showEventDetail(item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      imageUrl.isEmpty ? "https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800" : imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: navy.withOpacity(0.05),
                        child: const Icon(Icons.event_note_rounded, color: navy, size: 40),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: redAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                        ),
                        child: const Text('EVENT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: textGrey),
                          const SizedBox(width: 8),
                          Text(formattedDate, style: const TextStyle(color: textGrey, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: textGrey, fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Lihat Detail', style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 13)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, color: navy, size: 16),
                        ],
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

  void _showEventDetail(ActivityModel item) {
    String formattedDateFull = "-";
    try {
      final date = DateTime.parse(item.date);
      formattedDateFull = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      formattedDateFull = item.date;
    }

    String imageUrl = ApiConstants.getImageUrl(item.image);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        imageUrl.isEmpty ? "https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800" : imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 250,
                          color: navy.withOpacity(0.05),
                          child: const Icon(Icons.church_rounded, color: navy, size: 60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: navy.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                      child: const Text('DETAIL EVENT', style: TextStyle(color: navy, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 16),
                    Text(item.title, style: const TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: redAccent),
                        const SizedBox(width: 8),
                        Text(formattedDateFull, style: const TextStyle(color: redAccent, fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(),
                    ),
                    Text(
                      item.description,
                      style: const TextStyle(color: textDark, fontSize: 15, height: 1.8, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 60, color: textGrey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textGrey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
