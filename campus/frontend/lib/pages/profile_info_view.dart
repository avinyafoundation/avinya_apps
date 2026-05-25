import 'package:gallery/constants.dart';
import 'package:flutter/material.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:gallery/data/person.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

// ── Safe string helper ────────────────────────────────────────────────────────
// Converts any Object? field from the Person model to a display String.
// Fixes: "The argument type 'Object' can't be assigned to 'String'" errors.
String _s(Object? value) => (value == null || value.toString().trim().isEmpty)
    ? 'N/A'
    : value.toString();

// ── Screen ────────────────────────────────────────────────────────────────────

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with SingleTickerProviderStateMixin {
  late Person userPerson = Person(is_graduated: false)
    ..full_name = 'John'
    ..nic_no = '12';

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    getUserPerson();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void getUserPerson() {
    final Person user = campusAppsPortalInstance.getUserPerson();
    setState(() => userPerson = user);
  }

  // ── Safe derived values ───────────────────────────────────────────────────

  String get _displayName => _s(userPerson.full_name);

  String get _profileImage {
    final sex = userPerson.sex?.toString().toLowerCase().trim() ?? '';
    return sex == 'male'
        ? 'assets/images/student_profile_male.jpg'
        : 'assets/images/student_profile.jpeg';
  }

  String get _displayOrg => _s(userPerson.organization?.name?.name_en);

  String get _displayRegNo => _s(userPerson.id);

  String get _displayAcademicYear {
    if (userPerson.updated == null) return 'N/A';
    try {
      final dt = DateTime.parse(userPerson.updated.toString());
      final y1 = DateFormat('yyyy').format(dt);
      final y2 = DateFormat('yy').format(dt.add(const Duration(days: 365)));
      return '$y1/$y2';
    } catch (_) {
      return 'N/A';
    }
  }

  String get _displayProgramme => _s(userPerson.avinya_type?.focus);

  String _formatDate(Object? raw) {
    if (raw == null) return 'N/A';
    try {
      return DateFormat('d MMM, yyyy').format(DateTime.parse(raw.toString()));
    } catch (_) {
      return 'N/A';
    }
  }

  /// Safely reads a field from parent_students[index].
  String _parentField(int index, Object? Function(Person p) getter) {
    final parents = userPerson.parent_students;
    if (parents == null || parents.length <= index) return 'N/A';
    return _s(getter(parents[index]));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final DeviceType deviceType = SizerUtil.deviceType;
    final bool isTablet = deviceType == DeviceType.tablet;
    final bool isWeb = deviceType == DeviceType.web;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // ── Hero App Bar ──────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: isWeb
                    ? 180
                    : isTablet
                        ? 160
                        : 140,
                pinned: true,
                stretch: true,
                backgroundColor: const Color(0xFF1A1F36),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A1F36), Color(0xFF2D3561)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: isWeb
                                    ? 40
                                    : isTablet
                                        ? 36
                                        : 32,
                                backgroundColor: const Color(0xFF2D3561),
                                backgroundImage: AssetImage(_profileImage),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isWeb
                                      ? 16
                                      : isTablet
                                          ? 15
                                          : 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Quick Stats Bar ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _QuickStat(
                        label: 'Reg. Number',
                        value: _displayRegNo,
                        icon: Icons.badge_outlined,
                      ),
                      _StatDivider(),
                      _QuickStat(
                        label: 'Academic Year',
                        value: _displayAcademicYear,
                        icon: Icons.calendar_today_outlined,
                      ),
                      _StatDivider(),
                      _QuickStat(
                        label: 'Programme',
                        value: _displayProgramme,
                        icon: Icons.school_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Info Sections ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Student Information
                    _SectionCard(
                      title: 'Student Information',
                      icon: Icons.person_outline_rounded,
                      accentColor: const Color(0xFF4F5BD5),
                      children: [
                        _InfoTile(
                          label: 'Full Name',
                          value: _s(userPerson.full_name),
                        ),
                        _InfoTile(
                          label: 'Preferred Name',
                          value: _s(userPerson.preferred_name),
                        ),
                        _InfoTile(
                          label: 'Date of Birth',
                          value: _formatDate(userPerson.date_of_birth),
                        ),
                        _InfoTile(
                          label: 'Date of Admission',
                          value: _formatDate(userPerson.created),
                        ),
                        _InfoTile(
                          label: 'Gender',
                          value: _s(userPerson.sex),
                        ),
                        _InfoTile(
                          label: 'NIC Number',
                          value: _s(userPerson.nic_no),
                          isSensitive: true,
                        ),
                        _InfoTile(
                          label: 'Passport Number',
                          value: _s(userPerson.passport_no),
                          isSensitive: true,
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Contact Information
                    _SectionCard(
                      title: 'Contact Information',
                      icon: Icons.contact_phone_outlined,
                      accentColor: const Color(0xFF00B894),
                      children: [
                        _InfoTile(
                          label: 'Personal Phone',
                          value: _s(userPerson.phone),
                        ),
                        _InfoTile(
                          label: 'Avinya Phone',
                          value: _s(userPerson.avinya_phone),
                        ),
                        _InfoTile(
                          label: 'Email',
                          value: _s(userPerson.email),
                        ),
                        _InfoTile(
                          label: 'Home Address',
                          value:
                              _s(userPerson.permanent_address?.street_address),
                        ),
                        _InfoTile(
                          label: 'Mailing Address',
                          value: _s(userPerson.mailing_address?.street_address),
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bank Information
                    _SectionCard(
                      title: 'Bank Information',
                      icon: Icons.account_balance_outlined,
                      accentColor: const Color(0xFFF39C12),
                      children: [
                        _InfoTile(
                          label: 'Bank Name',
                          value: _s(userPerson.bank_name),
                        ),
                        _InfoTile(
                          label: 'Account Name',
                          value: _s(userPerson.bank_account_name),
                        ),
                        _InfoTile(
                          label: 'Account Number',
                          value: _s(userPerson.bank_account_number),
                          isSensitive: true,
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Parent / Guardian
                    _SectionCard(
                      title: 'Parent / Guardian',
                      icon: Icons.family_restroom_outlined,
                      accentColor: const Color(0xFFE84393),
                      children: [
                        _InfoTile(
                          label: 'Father Name',
                          value: _parentField(0, (p) => p.preferred_name),
                        ),
                        _InfoTile(
                          label: 'Father Phone',
                          value: _parentField(0, (p) => p.phone),
                        ),
                        _InfoTile(
                          label: 'Mother Name',
                          value: _parentField(1, (p) => p.preferred_name),
                        ),
                        _InfoTile(
                          label: 'Mother Phone',
                          value: _parentField(1, (p) => p.phone),
                          isLast: true,
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick Stat ────────────────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4F5BD5)),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: Colors.grey.shade200);
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: accentColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F36),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Accent underline
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 4),
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Info Tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    this.isSensitive = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isSensitive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1F36),
                  ),
                ),
              ),
              if (isSensitive)
                Icon(
                  Icons.lock_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}
