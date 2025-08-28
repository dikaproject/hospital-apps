import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/address_service.dart' as AddressAPI;
import '../main/main_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _showQRCode = false;
  String? _generatedQRCode;

  final _registerFormKey = GlobalKey<FormState>();

  // Register controllers
  final _regEmailController = TextEditingController();
  final _regNameController = TextEditingController();
  final _regNikController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  // Address controllers
  final _streetController = TextEditingController();
  final _manualVillageController = TextEditingController();
  final _manualDistrictController = TextEditingController();
  final _manualRegencyController = TextEditingController();
  final _manualProvinceController = TextEditingController();

  // Address data - gunakan prefix AddressAPI
  List<AddressAPI.Province> _provinces = [];
  List<AddressAPI.Regency> _regencies = [];
  List<AddressAPI.District> _districts = [];
  List<AddressAPI.Village> _villages = [];

  AddressAPI.Province? _selectedProvince;
  AddressAPI.Regency? _selectedRegency;
  AddressAPI.District? _selectedDistrict;
  AddressAPI.Village? _selectedVillage;

  bool _useManualAddress = false;
  bool _loadingProvinces = false;
  bool _loadingRegencies = false;
  bool _loadingDistricts = false;
  bool _loadingVillages = false;

  String? _registeredFingerprint;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadProvinces();
  }

  @override
  void dispose() {
    _regEmailController.dispose();
    _regNameController.dispose();
    _regNikController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _streetController.dispose();
    _manualVillageController.dispose();
    _manualDistrictController.dispose();
    _manualRegencyController.dispose();
    _manualProvinceController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await AuthService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
      });
    }
  }

  Future<void> _loadProvinces() async {
    if (mounted) {
      setState(() => _loadingProvinces = true);
    }

    try {
      final provinces = await AddressAPI.AddressService.getProvinces();
      if (mounted) {
        setState(() {
          _provinces = provinces;
          _loadingProvinces = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingProvinces = false);
        _showErrorSnackBar('Gagal memuat data provinsi: ${e.toString()}');
      }
    }
  }

  Future<void> _loadRegencies(String provinceId) async {
    if (mounted) {
      setState(() {
        _loadingRegencies = true;
        _selectedRegency = null;
        _selectedDistrict = null;
        _selectedVillage = null;
        _regencies.clear();
        _districts.clear();
        _villages.clear();
      });
    }

    try {
      final regencies =
          await AddressAPI.AddressService.getRegencies(provinceId);
      if (mounted) {
        setState(() {
          _regencies = regencies;
          _loadingRegencies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingRegencies = false);
        _showErrorSnackBar('Gagal memuat data kabupaten/kota: ${e.toString()}');
      }
    }
  }

  Future<void> _loadDistricts(String regencyId) async {
    if (mounted) {
      setState(() {
        _loadingDistricts = true;
        _selectedDistrict = null;
        _selectedVillage = null;
        _districts.clear();
        _villages.clear();
      });
    }

    try {
      final districts = await AddressAPI.AddressService.getDistricts(regencyId);
      if (mounted) {
        setState(() {
          _districts = districts;
          _loadingDistricts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingDistricts = false);
        _showErrorSnackBar('Gagal memuat data kecamatan: ${e.toString()}');
      }
    }
  }

  Future<void> _loadVillages(String districtId) async {
    if (mounted) {
      setState(() {
        _loadingVillages = true;
        _selectedVillage = null;
        _villages.clear();
      });
    }

    try {
      final villages = await AddressAPI.AddressService.getVillages(districtId);
      if (mounted) {
        setState(() {
          _villages = villages;
          _loadingVillages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingVillages = false);
        _showErrorSnackBar('Gagal memuat data kelurahan: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF2E7D89),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.7, 1.0],
            colors: [
              Color(0xFF52B69A),
              Color(0xFF34A0A4),
              Color(0xFF2E7D89),
              Color(0xFF1A535C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: _showQRCode
                      ? _buildQRCodeView()
                      : _buildRegisterContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_add,
              color: Color(0xFF2E7D89),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Buat Akun Baru',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Daftar untuk menggunakan HospitalLink',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF52B69A), Color(0xFF34A0A4)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Registrasi Berhasil!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D89),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'QR Code Anda telah dibuat. Simpan QR Code ini untuk check-in cepat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: QrImageView(
              data: _generatedQRCode ?? '',
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF52B69A), Color(0xFF34A0A4)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF34A0A4).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Lanjut ke Aplikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _registerFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildSectionTitle('Informasi Pribadi'),
              _buildTextField(
                controller: _regEmailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email harus diisi';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _regNameController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Alamat'),
              _buildTextField(
                controller: _streetController,
                label: 'Jalan/Alamat',
                icon: Icons.home_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _useManualAddress,
                    onChanged: (value) {
                      setState(() {
                        _useManualAddress = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF2E7D89),
                  ),
                  const Text('Isi alamat manual'),
                ],
              ),
              const SizedBox(height: 16),
              if (_useManualAddress)
                ..._buildManualAddressFields()
              else
                ..._buildDropdownAddressFields(),
              const SizedBox(height: 24),
              _buildSectionTitle('Informasi Akun'),
              _buildTextField(
                controller: _regNikController,
                label: 'NIK (16 digit)',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIK harus diisi';
                  }
                  if (!AuthService.isValidNIK(value)) {
                    return 'NIK harus 16 digit angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _regPasswordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password harus diisi';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _regConfirmPasswordController,
                label: 'Konfirmasi Password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password harus diisi';
                  }
                  if (value != _regPasswordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_isBiometricAvailable) ...[
                _buildSectionTitle('Keamanan Biometrik (Opsional)'),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green[50] ?? Colors.green.shade50,
                        Colors.green[100] ?? Colors.green.shade100,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.green[200] ?? Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _registeredFingerprint != null
                                ? Icons.check_circle
                                : Icons.fingerprint,
                            color: _registeredFingerprint != null
                                ? Colors.green
                                : const Color(0xFF2E7D89),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _registeredFingerprint != null
                                  ? 'Fingerprint berhasil didaftarkan'
                                  : 'Daftarkan fingerprint untuk keamanan ekstra',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_registeredFingerprint == null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _registerFingerprint,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Daftar Fingerprint'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2E7D89),
                              side: const BorderSide(color: Color(0xFF2E7D89)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF52B69A), Color(0xFF34A0A4)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF34A0A4).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Masuk disini',
                      style: TextStyle(
                        color: Color(0xFF2E7D89),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D89),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D89)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: Colors.grey[300] ?? Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: Colors.grey[300] ?? Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF2E7D89), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50] ?? Colors.grey.shade50,
      ),
      validator: validator,
    );
  }

  List<Widget> _buildManualAddressFields() {
    return [
      _buildTextField(
        controller: _manualVillageController,
        label: 'Kelurahan/Desa',
        icon: Icons.location_city_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Kelurahan/Desa harus diisi';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _manualDistrictController,
        label: 'Kecamatan',
        icon: Icons.location_city_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Kecamatan harus diisi';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _manualRegencyController,
        label: 'Kabupaten/Kota',
        icon: Icons.location_city_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Kabupaten/Kota harus diisi';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _manualProvinceController,
        label: 'Provinsi',
        icon: Icons.location_city_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Provinsi harus diisi';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildDropdownAddressFields() {
    return [
      // Provinsi Dropdown
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300] ?? Colors.grey.shade300),
        ),
        child: DropdownButtonFormField<AddressAPI.Province>(
          value: _selectedProvince,
          decoration: InputDecoration(
            labelText: 'Provinsi',
            prefixIcon:
                const Icon(Icons.location_city, color: Color(0xFF2E7D89)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[50] ?? Colors.grey.shade50,
          ),
          items: _provinces.map<DropdownMenuItem<AddressAPI.Province>>(
              (AddressAPI.Province province) {
            return DropdownMenuItem<AddressAPI.Province>(
              value: province,
              child: Text(province.name),
            );
          }).toList(),
          onChanged: _loadingProvinces
              ? null
              : (AddressAPI.Province? newValue) {
                  setState(() {
                    _selectedProvince = newValue;
                    _selectedRegency = null;
                    _selectedDistrict = null;
                    _selectedVillage = null;
                    _regencies.clear();
                    _districts.clear();
                    _villages.clear();
                  });
                  if (newValue != null) {
                    _loadRegencies(newValue.id);
                  }
                },
          validator: (value) {
            if (value == null) {
              return 'Provinsi harus dipilih';
            }
            return null;
          },
        ),
      ),

      const SizedBox(height: 16),

      // Kabupaten/Kota Dropdown
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300] ?? Colors.grey.shade300),
        ),
        child: DropdownButtonFormField<AddressAPI.Regency>(
          value: _selectedRegency,
          decoration: InputDecoration(
            labelText: 'Kabupaten/Kota',
            prefixIcon:
                const Icon(Icons.location_city, color: Color(0xFF2E7D89)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[50] ?? Colors.grey.shade50,
          ),
          items: _regencies.map<DropdownMenuItem<AddressAPI.Regency>>(
              (AddressAPI.Regency regency) {
            return DropdownMenuItem<AddressAPI.Regency>(
              value: regency,
              child: Text(regency.name),
            );
          }).toList(),
          onChanged: _loadingRegencies || _selectedProvince == null
              ? null
              : (AddressAPI.Regency? newValue) {
                  setState(() {
                    _selectedRegency = newValue;
                    _selectedDistrict = null;
                    _selectedVillage = null;
                    _districts.clear();
                    _villages.clear();
                  });
                  if (newValue != null) {
                    _loadDistricts(newValue.id);
                  }
                },
          validator: (value) {
            if (value == null && _selectedProvince != null) {
              return 'Kabupaten/Kota harus dipilih';
            }
            return null;
          },
        ),
      ),

      const SizedBox(height: 16),

      // Kecamatan Dropdown
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300] ?? Colors.grey.shade300),
        ),
        child: DropdownButtonFormField<AddressAPI.District>(
          value: _selectedDistrict,
          decoration: InputDecoration(
            labelText: 'Kecamatan',
            prefixIcon:
                const Icon(Icons.location_city, color: Color(0xFF2E7D89)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[50] ?? Colors.grey.shade50,
          ),
          items: _districts.map<DropdownMenuItem<AddressAPI.District>>(
              (AddressAPI.District district) {
            return DropdownMenuItem<AddressAPI.District>(
              value: district,
              child: Text(district.name),
            );
          }).toList(),
          onChanged: _loadingDistricts || _selectedRegency == null
              ? null
              : (AddressAPI.District? newValue) {
                  setState(() {
                    _selectedDistrict = newValue;
                    _selectedVillage = null;
                    _villages.clear();
                  });
                  if (newValue != null) {
                    _loadVillages(newValue.id);
                  }
                },
          validator: (value) {
            if (value == null && _selectedRegency != null) {
              return 'Kecamatan harus dipilih';
            }
            return null;
          },
        ),
      ),

      const SizedBox(height: 16),

      // Kelurahan/Desa Dropdown
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300] ?? Colors.grey.shade300),
        ),
        child: DropdownButtonFormField<AddressAPI.Village>(
          value: _selectedVillage,
          decoration: InputDecoration(
            labelText: 'Kelurahan/Desa',
            prefixIcon:
                const Icon(Icons.location_city, color: Color(0xFF2E7D89)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[50] ?? Colors.grey.shade50,
          ),
          items: _villages.map<DropdownMenuItem<AddressAPI.Village>>(
              (AddressAPI.Village village) {
            return DropdownMenuItem<AddressAPI.Village>(
              value: village,
              child: Text(village.name),
            );
          }).toList(),
          onChanged: _loadingVillages || _selectedDistrict == null
              ? null
              : (AddressAPI.Village? newValue) {
                  setState(() {
                    _selectedVillage = newValue;
                  });
                },
          validator: (value) {
            if (value == null && _selectedDistrict != null) {
              return 'Kelurahan/Desa harus dipilih';
            }
            return null;
          },
        ),
      ),
    ];
  }

  Future<void> _registerFingerprint() async {
    try {
      final fingerprintData = await AuthService.registerFingerprint();
      if (fingerprintData != null) {
        setState(() {
          _registeredFingerprint = fingerprintData;
        });
        _showSuccessSnackBar('Fingerprint berhasil didaftarkan!');
      } else {
        _showErrorSnackBar('Gagal mendaftarkan fingerprint');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _handleRegister() async {
    if (_registerFormKey.currentState?.validate() == true) {
      setState(() => _isLoading = true);

      try {
        String? addressData;
        if (_useManualAddress) {
          addressData =
              '${_streetController.text}, ${_manualVillageController.text}, ${_manualDistrictController.text}, ${_manualRegencyController.text}, ${_manualProvinceController.text}';
        }

        print(
            '🔄 Registering with fingerprint: $_registeredFingerprint'); // Debug

        final user = await AuthService.register(
          email: _regEmailController.text,
          fullName: _regNameController.text,
          password: _regPasswordController.text,
          nik:
              _regNikController.text.isNotEmpty ? _regNikController.text : null,
          street: _useManualAddress ? addressData : _streetController.text,
          village: _useManualAddress ? null : _selectedVillage?.name,
          district: _useManualAddress ? null : _selectedDistrict?.name,
          regency: _useManualAddress ? null : _selectedRegency?.name,
          province: _useManualAddress ? null : _selectedProvince?.name,
          fingerprintData: _registeredFingerprint,
        );

        if (mounted) {
          setState(() => _isLoading = false);

          if (user != null) {
            print(
                '✅ User registered with fingerprint: ${user.fingerprintData}'); // Debug

            // Manually save fingerprint to SharedPreferences as backup
            if (_registeredFingerprint != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                  'fingerprint_data', _registeredFingerprint!);
              print('🔒 Backup fingerprint saved: $_registeredFingerprint');
            }

            _generatedQRCode = user.qrCode;
            setState(() => _showQRCode = true);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('Error: ${e.toString()}');
        }
      }
    }
  }
}
