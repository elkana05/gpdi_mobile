import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class JadwalIbadahScreen extends StatefulWidget {
  const JadwalIbadahScreen({super.key});

  @override
  State<JadwalIbadahScreen> createState() => _JadwalIbadahScreenState();
}

class _JadwalIbadahScreenState extends State<JadwalIbadahScreen> {
  // Warna disesuaikan dengan Web React
  static const Color navy = Color(0xFF0D1282);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Colors.white;

  bool isLoading = true;
  String errorMsg = '';
  List<dynamic> worshipSchedules = [];
  List<dynamic> events = [];

  // Filter & Search states
  String selectedCategory = "Semua Kegiatan";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<String> kategoriOptions = [
    "Semua Kegiatan",
    "Ibadah Raya Minggu",
    "Ibadah Sekolah Minggu",
    "Ibadah Pemuda & Remaja",
    "Ibadah Wanita (Pelwap)",
    "Doa Malam Jemaat"
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    try {
      final results = await Future.wait([
        ApiClient().get(ApiConstants.worshipSchedules),
        ApiClient().get(ApiConstants.activitySchedules),
      ]);

      if (mounted) {
        setState(() {
          worshipSchedules = results[0] is List ? results[0] : (results[0]['data'] ?? []);
          events = results[1] is List ? results[1] : (results[1]['data'] ?? []);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = "Gagal memuat data jadwal.";
          isLoading = false;
        });
      }
    }
  }

  // Filter logic matching the React 'useMemo'
  List<dynamic> get _filteredWorship {
    return worshipSchedules.where((item) {
      final String cat = (item['category'] ?? item['nama_ibadah'] ?? item['nama'] ?? "").toString();
      final bool matchKat = selectedCategory == "Semua Kegiatan" || cat == selectedCategory;

      final String q = searchQuery.toLowerCase();
      final String hari = (item['day_of_week'] ?? item['hari'] ?? "").toString().toLowerCase();
      final String tempat = (item['location'] ?? item['tempat'] ?? "").toString().toLowerCase();
      final String nama = cat.toLowerCase();

      final bool matchCari = hari.contains(q) || nama.contains(q) || tempat.contains(q);

      return matchKat && matchCari;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.jadwalIbadah),
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: navy, size: 27),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Jadwal & Kegiatan',
          style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchData,
            color: navy,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                    child: Column(
                      children: [
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 30),

                        _buildSectionTitle("Jadwal Ibadah Rutin"),
                        const SizedBox(height: 25),

                        _buildFilterControls(),
                        const SizedBox(height: 20),

                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(color: navy),
                          )
                        else if (errorMsg.isNotEmpty)
                          _buildErrorState()
                        else if (_filteredWorship.isEmpty)
                          _buildEmptyState("Tidak ada jadwal ibadah yang ditemukan.")
                        else
                          ..._filteredWorship.map((s) => _buildScheduleCard(s)),

                        const SizedBox(height: 50),
                        _buildSectionTitle("Kegiatan Khusus / Event"),
                        const SizedBox(height: 30),

                        if (!isLoading)
                          if (events.isEmpty)
                            _buildEmptyState("Tidak ada event khusus dalam waktu dekat.")
                          else
                            ...events.map((e) => _buildEventCard(e)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigation(currentIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      child: Column(
        children: [
          const Text(
            "Jadwal Ibadah & Kegiatan",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: navy,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Informasi Jadwal Ibadah Rutin dan Kegiatan Gereja",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 25),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              "https://images.unsplash.com/photo-1438232992991-995b7058bbb3?q=80&w=1440&auto=format&fit=crop",
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: navy,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildFilterControls() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showCategoryPicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCategory,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155), fontSize: 14),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: "Cari Hari/Tempat...",
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: navy, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("Pilih Kategori", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: navy)),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: kategoriOptions.map((k) => ListTile(
                    title: Text(k, style: TextStyle(
                      color: selectedCategory == k ? navy : Colors.black87,
                      fontWeight: selectedCategory == k ? FontWeight.w800 : FontWeight.w500,
                    )),
                    trailing: selectedCategory == k ? const Icon(Icons.check_circle, color: navy) : null,
                    onTap: () {
                      setState(() => selectedCategory = k);
                      Navigator.pop(context);
                    },
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleCard(dynamic item) {
    final String title = item['category'] ?? item['nama_ibadah'] ?? item['nama'] ?? '-';
    final String day = item['day_of_week'] ?? item['hari'] ?? '-';
    final String time = item['start_time'] ?? item['jam'] ?? item['waktu'] ?? '-';
    final String loc = item['location'] ?? item['tempat'] ?? '-';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.access_time_filled, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text("$time WIB", style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600)),
              const SizedBox(width: 25),
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text(loc, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic item) {
    final String title = item['judul'] ?? item['title'] ?? item['nama_kegiatan'] ?? '-';
    final String desc = item['description'] ?? item['deskripsi'] ?? '';
    final String dateStr = item['event_date'] ?? item['tanggal'] ?? '';
    final String img = item['gambar'] ?? '';

    String formattedDate = '-';
    if (dateStr.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(dateStr);
        formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
      } catch (e) {
        formattedDate = dateStr;
      }
    }

    final imageUrl = img.isNotEmpty
      ? (img.startsWith('http') ? img : "${ApiConstants.host}/storage/$img")
      : "https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800";

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey)
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: redAccent, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                  child: const Text("EVENT KHUSUS", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Tanggal", style: TextStyle(fontWeight: FontWeight.w900, color: redAccent, fontSize: 14)),
                    Text(" : $formattedDate", style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  desc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic, height: 1.5, fontSize: 14),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showEventDetail(item, formattedDate, imageUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Lihat Detail", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetail(dynamic item, String date, String imageUrl) {
    final String title = item['judul'] ?? item['title'] ?? item['nama_kegiatan'] ?? '-';
    final String desc = item['description'] ?? item['deskripsi'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                        child: Image.network(
                          imageUrl,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            height: 280,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)
                          ),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        top: 15,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.4),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(color: navy.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: const Text("DETAIL EVENT", style: TextStyle(color: navy, fontSize: 11, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(height: 18),
                        Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: navy, height: 1.2)),
                        const SizedBox(height: 12),
                        Text("📅 $date", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: redAccent)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(),
                        ),
                        Text(
                          desc,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF334155), height: 1.8, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: redAccent, size: 48),
          const SizedBox(height: 12),
          Text(errorMsg, style: const TextStyle(color: redAccent, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Coba Lagi"),
            style: TextButton.styleFrom(foregroundColor: navy),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
