import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _temperatureUnit = '섭씨';
  double _nozzleTemperature = 200.0;
  double _bedTemperature = 60.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _temperatureUnit = prefs.getString('temperature_unit') ?? '섭씨';
      _nozzleTemperature = prefs.getDouble('nozzle_temperature') ?? 200.0;
      _bedTemperature = prefs.getDouble('bed_temperature') ?? 60.0;
    });
  }

  _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setString('temperature_unit', _temperatureUnit);
    await prefs.setDouble('nozzle_temperature', _nozzleTemperature);
    await prefs.setDouble('bed_temperature', _bedTemperature);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('프린터 설정'),
          ListTile(
            title: const Text('기본 노즐 온도'),
            subtitle: Text('${_nozzleTemperature.toStringAsFixed(1)}°${_temperatureUnit == '섭씨' ? 'C' : 'F'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTemperatureDialog('노즐', _nozzleTemperature, (value) {
              setState(() => _nozzleTemperature = value);
              _saveSettings();
            }),
          ),
          ListTile(
            title: const Text('기본 베드 온도'),
            subtitle: Text('${_bedTemperature.toStringAsFixed(1)}°${_temperatureUnit == '섭씨' ? 'C' : 'F'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTemperatureDialog('베드', _bedTemperature, (value) {
              setState(() => _bedTemperature = value);
              _saveSettings();
            }),
          ),
          ListTile(
            title: const Text('온도 단위'),
            subtitle: Text(_temperatureUnit),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showTemperatureUnitDialog,
          ),
          _buildSectionHeader('앱 설정'),
          SwitchListTile(
            title: const Text('알림'),
            subtitle: const Text('프린트 완료 및 오류 알림'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() => _notificationsEnabled = value);
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text('다크 모드'),
            subtitle: const Text('어두운 테마 사용'),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme();
            },
          ),
          _buildSectionHeader('정보'),
          ListTile(
            title: const Text('앱 버전'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('오픈소스 라이선스'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 오픈소스 라이선스 화면으로 이동
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showTemperatureUnitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('온도 단위 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text('섭씨 (°C)'),
                value: '섭씨',
                groupValue: _temperatureUnit,
                onChanged: (value) {
                  setState(() => _temperatureUnit = value.toString());
                  _saveSettings();
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile(
                title: const Text('화씨 (°F)'),
                value: '화씨',
                groupValue: _temperatureUnit,
                onChanged: (value) {
                  setState(() => _temperatureUnit = value.toString());
                  _saveSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTemperatureDialog(String type, double currentTemp, Function(double) onChanged) {
    TextEditingController textController = TextEditingController(text: currentTemp.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('$type 온도 설정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: currentTemp,
                    min: 0,
                    max: 300,
                    divisions: 300,
                    label: currentTemp.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        currentTemp = value;
                        textController.text = value.toStringAsFixed(1);
                      });
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            suffixText: _temperatureUnit == '섭씨' ? '°C' : '°F',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            double? newTemp = double.tryParse(value);
                            if (newTemp != null && newTemp >= 0 && newTemp <= 300) {
                              setState(() {
                                currentTemp = newTemp;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    double? finalTemp = double.tryParse(textController.text);
                    if (finalTemp != null && finalTemp >= 0 && finalTemp <= 300) {
                      onChanged(finalTemp);
                    } else {
                      onChanged(currentTemp);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
