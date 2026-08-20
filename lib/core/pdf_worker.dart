import 'dart:typed_data';
import 'package:isolate_manager/isolate_manager.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

@pragma('vm:entry-point')
@isolateManagerWorker
Future<Uint8List> peminjamanPeralatanCompilePdfWorker(dynamic form) async {
  final ttf = form['ttf'];
  final ttfBold = form['ttfBold'];
  final ttfItalic = form['ttfItalic'];

  final String? nama = form['nama'];
  final String? nim = form['nim'];
  final String fakultas = form['fakultas'] ?? "__________";
  final String prodi = form['prodi'] ?? "__________";
  final String? dosen = form['dosen'];
  final String? nipDosen = form['nipDosen'];
  final String ketua = form['ketua'] ?? "";
  final String nipKetua = form['nipKetua'] ?? "";

  final mulai = form['mulai'] ?? "_______________________";
  final akhir = form['akhir'] ?? "_____________________";

  final List<String> barang = form['barang'].map((e) {
    return e == null || e.trim().isEmpty
      ? "_____________________________________________________________________" 
      : e.trim();
  }).toList();
  final List<String> banyak = form['banyak'].map(
    (e) => e == null ? "" : 'x$e'
  ).toList();

  final Uint8List? idCard = form['idCard'] is Uint8List ? form ['idCard'] : null;

  final pdf = pw.Document();
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.letter,
    theme: pw.ThemeData.withFont(
      base: pw.Font.ttf(ttf),
      bold: pw.Font.ttf(ttfBold),
      italic: pw.Font.ttf(ttfItalic),
    ),
    margin: pw.EdgeInsets.fromLTRB(72, 36, 72, 36),
    footer: (context) {
      if (context.pageNumber == 1) {
        return pw.DefaultTextStyle(
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.normal,
            fontSize: 11,
            lineSpacing: 5
          ),
          child: pw.Transform.translate(
            offset: PdfPoint(0, 0), 
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Catatan:", textAlign: pw.TextAlign.justify),
                pw.SizedBox(height: 2.0),
                pw.Text("1. Surat pernyataan ini sekaligus sebagai tanda terima barang.", textAlign: pw.TextAlign.justify),
                pw.SizedBox(height: 2.0),
                pw.Text("2. Peminjam selain Prodi Teknik Elektro wajib menyertakan tanda tangan kaprodi.", textAlign: pw.TextAlign.justify),
              ]
            )
          )
        );
      } 
      return pw.Container();
    }, 
    build: (pw.Context context) => [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text("FORM PEMINJAMAN PERALATAN", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text("LABORATORIUM DASAR TEKNIK ELEKTRO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text("SEKOLAH TEKNIK ELEKTRO DAN INFORMATIKA", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ]
            )
          ),
          pw.SizedBox(height: 22),
          pw.Text("Saya yang bertanda tangan dibawah ini:"),
          pw.SizedBox(height: 22),
          pw.Text("Nama/NIM : ${nama ?? "______________________________"} / ${nim ?? "_________________"}"),
          pw.SizedBox(height: 22),
          pw.Text("adalah mahasiswa program studi $prodi $fakultas ITB, dengan pembimbing:"),
          pw.SizedBox(height: 22),
          pw.Text("Dosen Pembimbing: ${dosen ?? "______________________________"}"),
          pw.SizedBox(height: 22),
          pw.Text("Hendak meminjam sejumlah peralatan dari Laboratorium Dasar Teknik Elektro STEI:"),
          pw.Padding(
            padding: pw.EdgeInsets.only(left: 18),
            child: pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(18),
                1: const pw.FlexColumnWidth(),
              },
              children: [
                for (int i = 0; i < barang.length || i < banyak.length; i++) ...[
                  pw.TableRow(children: [pw.SizedBox(height: 5)]),
                  pw.TableRow(children: [
                    pw.Text('${i + 1}.'),
                    pw.Text('${barang.elementAtOrNull(i) ?? '_____________________________________________________________________'} ${banyak.elementAtOrNull(i) ?? 'x'}'),
                  ]),
                ]
              ],
            )
          ),
          pw.SizedBox(height: 22),
          pw.Text("Peminjaman saya lakukan mulai tanggal $mulai"),
          pw.SizedBox(height: 5),
          pw.Text("dan akan dikembalikan tanggal $akhir"),
          pw.SizedBox(height: 22),
          pw.Text("Saya berjanji untuk bertanggung jawab sepenuhnya terhadap barang yang saya pinjam dengan:"),
          pw.SizedBox(height: 22),
          pw.Padding(
            padding: pw.EdgeInsets.only(left: 18),
            child: pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(18),
                1: const pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(children: [
                  pw.Text("1."),
                  pw.Text("Tidak menyalahgunakan peralatan tersebut, termasuk untuk kegiatan diluar akademis", textAlign: pw.TextAlign.justify),
                ]),
                pw.TableRow(children: [pw.SizedBox(height: 5)]),
                pw.TableRow(children: [
                  pw.Text("2."),
                  pw.Text("Mengembalikan dalam kondisi baik sebagaimana saat diterima, dan bersedia bertanggung jawab sepenuhnya terhadap segala macam kerusakan dan kehilangan.", textAlign: pw.TextAlign.justify),
                ]),
              ]
            ),
          ),
          pw.SizedBox(height: 22),
          pw.Center(
            child: pw.Text("Bandung, ______________________"),
          ),
          pw.SizedBox(height: 5),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 57),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Peminjam,'),
                    pw.SizedBox(height: 40),
                    pw.Text('Nama: ${nama ?? ''}'),
                    pw.SizedBox(height: 5),
                    pw.Text('NIM: ${nim ?? ''}'),
                  ]
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Dosen Pembimbing,'),
                    pw.SizedBox(height: 40,),
                    pw.Text('Nama: ${dosen ?? ''}'),
                    pw.SizedBox(height: 5),
                    pw.Text('NIP: ${nipDosen ?? ''}'),
                  ]
                ),
              ]
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text("Mengetahui,"),
                pw.SizedBox(height: 5),
                pw.Text("Ketua Prodi $prodi"),  
                pw.SizedBox(height: 40,),
                pw.Container(
                  constraints: pw.BoxConstraints(minWidth: 160),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Nama: $ketua"),
                      pw.SizedBox(height: 5),
                      pw.Text('NIP: $nipKetua')
                    ]
                  ),
                )
              ],
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.only(left :18),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 36),
                pw.Text("ATURAN PEMINJAMAN PERALATAN LABORATORIUM DASAR TEKNIK ELEKTRO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 17),
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(18),
                    1: const pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(children: [pw.SizedBox(height: 5)]),
                    pw.TableRow(children: [
                      pw.Text('1.'),
                      pw.Text('Peminjam adalah mahasiswa program S1 Teknik Elektro ITB, dengan rekomendasi dosen pembimbing, atau sivitas akademik lain di lingkungan STEI.'),
                    ]),
                    pw.TableRow(children: [pw.SizedBox(height: 5)]),
                    pw.TableRow(children: [
                      pw.Text('2.'),
                      pw.Text('Peminjam selain mahasiswa S1/S2 Teknik Elektro, selain menyertakan rekomendasi dosen pembimbing, juga wajib mendapatkan rekomendasi dari KaProdi bersangkutan.'),
                    ]),
                    pw.TableRow(children: [pw.SizedBox(height: 5)]),
                    pw.TableRow(children: [
                      pw.Text('3.'),
                      pw.Text('Peralatan seperti signal generator, multimeter, osciloscope, logic analyzer, spektrum analyzer, dan sejenisnya hanya boleh dipinjam dan dipergunakan di lab dasar.'),
                    ]),
                    pw.TableRow(children: [pw.SizedBox(height: 5)]),
                    pw.TableRow(children: [
                      pw.Text('4.'),
                      pw.Text('Peminjam bertanggungjawab sepenuhnya terhadap barang/peralatan yang dipinjam.'),
                    ]),
                    pw.TableRow(children: [pw.SizedBox(height: 5)]),
                    pw.TableRow(children: [
                      pw.Text('5.'),
                      pw.Text('Cara melakukan peminjaman (development kit):'),
                    ]),
                    pw.TableRow(children: [pw.SizedBox(height: 5)]),
                    pw.TableRow(children: [
                      pw.Text(''),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FixedColumnWidth(18),
                          1: const pw.FlexColumnWidth(),
                        },
                        children: [
                          pw.TableRow(children: [pw.SizedBox(height: 5)]),
                          pw.TableRow(children: [
                            pw.Text('a.'),
                            pw.Text('mahasiswa menghubungi teknisi Lab Dasar untuk menanyakan ketersediaan alat.'),
                          ]),
                          pw.TableRow(children: [pw.SizedBox(height: 5)]),
                          pw.TableRow(children: [
                            pw.Text('b.'),
                            pw.Text('mahasiswa mengisi form peminjaman online dan offline serta meminta tanda tangan / rekomendasi pembimbing dan kaprodi (jika diperlukan).'),
                          ]),
                          pw.TableRow(children: [pw.SizedBox(height: 5)]),
                          pw.TableRow(children: [
                            pw.Text('c.'),
                            pw.Text('mahasiswa menyerahkan form peminjaman yang telah diisi dan ditandatangani secara lengkap kepada teknisi, dan teknisi mencocokkan identitas peminjam.'),
                          ]),
                          pw.TableRow(children: [pw.SizedBox(height: 5)]),
                          pw.TableRow(children: [
                            pw.Text('d.'),
                            pw.Text('Mahasiswa menerima peralatan yang dipinjam. Jika ingin mencoba di Lab, harus dilakukan oleh teknisi didepan peminjam.'),
                          ]),
                          pw.TableRow(children: [pw.SizedBox(height: 5)]),
                          pw.TableRow(children: [
                            pw.Text('e.'),
                            pw.Text('Pada tanggal yang ditentukan, mahasiswa mengembalikan peralatan yang dipinjam ke teknisi. Teknisi mencoba / melakukan pengetesan dan memeriksa bahwa peralatan masih dalam kondisi baik dan lengkap.'),
                          ]),
                          pw.TableRow(children: [pw.SizedBox(height: 5)]),
                          pw.TableRow(children: [
                            pw.Text('f.'),
                            pw.Text('Proses pengambilan dan pengembalian harus dilakukan oleh mahasiswa yang namanya tertera di form peminjaman.'),
                          ]),
                        ]
                      )
                    ]),
                    pw.TableRow(children: [pw.SizedBox(height: 5)]),
                    pw.TableRow(children: [
                      pw.Text('6.'),
                      pw.Text('Segala hal yang belum tercantum dalam aturan ini akan ditetapkan kemudian.'),
                    ]),
                    pw.TableRow(children: [pw.SizedBox(height: 5)]),
                    pw.TableRow(children: [
                      pw.Text('7.'),
                      pw.Text('Peserta melampirkan foto KTM dan KTP pada form ini.'),
                    ]),
                  ],
                )
              ]
            )
          ),
          pw.SizedBox(height: 22),
          pw.Text('Bandung, Maret 2021'),
          pw.SizedBox(height: 5),
          pw.Text('Lab Dasar Teknik Elektro'),
          pw.SizedBox(height: 5),
          pw.Text('STEI - ITB'),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 36),
              pw.Text("Lamipran", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('\n'),
              pw.Text('Foto / Scan Kartu Identitas :'),
              if (idCard != null) ...[
                pw.Container(
                  constraints: pw.BoxConstraints(
                    maxHeight: 15.wcm,
                    maxWidth: 15.wcm,
                  ),
                  child: pw.Image(pw.MemoryImage(idCard)),
                ),
                pw.Text('\n'),
              ]
            ]
          ),
        ]
      ),
    ]
  ));
  return pdf.save();
}

@pragma('vm:entry-point')
@isolateManagerWorker
  Future<Uint8List> suratKeteranganPraktikumCompilePdfWorker(dynamic params) {
    final Uint8List fontBytes = params['fontBytes'];
    final Uint8List headerBytes = params['headerBytes'];
    final Uint8List footerBytes = params['footerBytes'];
    final Uint8List buktiBytes = params['buktiBytes'];
    
    final String nomorSurat = params['nomor_surat'];
    final String namaKepalaLDTE = params['nama_kepala_ldte'];
    final String nipKepalaLDTE = params['nip_kepala_ldte'];

    final String today = params['today'];
    final String timeStart = params['timeStart'];
    final String timeEnd = params['timeEnd'];
    final String matkul = params['matkul'];
    final String praktikum = params['praktikum'];
    final int modul = params['modul'];
    final String date = params['date'];

    final List<String> nama = List<String>.from(params['nama']);
    final List<String> nim = List<String>.from(params['nim']);

    final ttfFont = pw.Font.ttf(ByteData.sublistView(fontBytes));

    final headerImage = pw.MemoryImage(headerBytes);
    final footerImage = pw.MemoryImage(footerBytes);
    final buktiImage = pw.MemoryImage(buktiBytes);

    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(
        base: ttfFont
      ),
      margin: pw.EdgeInsets.fromLTRB(2.wcm, 0, 2.wcm, 5.wmm),
      header: (context) => pw.Image(headerImage, width: PdfPageFormat.a4.availableWidth),
      footer: (context) => pw.Image(footerImage, width: PdfPageFormat.a4.availableWidth),
      build: (pw.Context context) => [
        pw.DefaultTextStyle(
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.normal,
            fontSize: 11,
            lineSpacing: 1
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Table(
                columnWidths: {
                  0: pw.FixedColumnWidth(26.wmm),
                  1: pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Nomor'),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(': $nomorSurat'),
                          pw.Text(today),
                        ],
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                     pw.Text('Lampiran'),
                     pw.Text(': -'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text('Perihal'),
                      pw.Text(': Surat Keterangan Praktikum'),
                    ],
                  ),
                ],
              ),  

              pw.Text('\n\n\n'),

              pw.Center(
                child: pw.Text(
                  'SURAT KETERANGAN PRAKTIKUM',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.Text('\n\n'),

              pw.Text(
                'Melalui surat ini, diberitahukan bahwa mahasiswa dengan '
                'nama dan NIM di bawah ini tidak dapat mengikuti mata '
                'kuliah $matkul karena mengikuti '
                '$praktikum modul $modul yang '
                'dilaksanakan secara luring di Laboratorium Dasar '
                'Teknik Elektro pada',
                textAlign: pw.TextAlign.justify,
              ),

              pw.Text('\n'),

              pw.Center(
                child: pw.SizedBox(
                  width: 8.82.wcm,
                  child: pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(100),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Text('Hari, Tanggal'),
                          pw.Text(': $date'),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text('Pukul'),
                          pw.Text(': $timeStart – $timeEnd WIB'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              pw.Text('\n'),

              pw.Center(
                child: pw.SizedBox(
                  width: 10.wcm,
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(80),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      for (var i = 0; i < nama.length; i++) ...[
                        pw.TableRow(children: [
                          pw.Text(nim[i], textAlign: pw.TextAlign.center),
                          pw.Text('  ${nama[i]}'),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),

              pw.Text('\n'),

              pw.Text('Demikian surat keterangan ini dibuat agar dapat dipergunakan sebagaimana mestinya.' ),

              pw.Text('\n\n'),

              pw.Container(
                padding: pw.EdgeInsets.only(right: 2.wcm),
                alignment: pw.Alignment.topRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Kepala Lab. Dasar Teknik Elektro,'),

                    pw.Text('\n\n\n\n\n\n'),

                    pw.Text(
                      namaKepalaLDTE,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.Text('NIP.: $nipKepalaLDTE'),
                  ],
                ),
              ),
            ]
          ),
        ),
        pw.NewPage(),
        pw.Text('Bukti Screenshot Jadwal Praktikum :', style: pw.TextStyle(fontSize: 11)),
        pw.Text('\n'),
        if (true) pw.Container(
          constraints: pw.BoxConstraints(
            maxHeight: 15.wcm,
            maxWidth: 15.wcm,
          ),
          child: pw.Image(buktiImage),
        ),
      ]
    ));
    
    return pdf.save();
  }

extension DoubleEx on double {
  double get wcm => this * PdfPageFormat.cm;

  double get wmm => this * PdfPageFormat.mm;
}

extension IntEx on int {
  double get wcm => this * PdfPageFormat.cm;

  double get wmm => this * PdfPageFormat.mm;
}