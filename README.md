# eForm LDTE

A digital form submission and management system for **Laboratorium Dasar Teknik Elektro (LDTE)**, Sekolah Teknik Elektro dan Informatika (STEI), Institut Teknologi Bandung (ITB).

eForm LDTE was developed to digitize several administrative processes that were previously handled using physical forms and manual procedures. The application allows students to submit forms digitally, while providing administrators with tools to manage submissions, data, and application configuration.

## Features

### Student

- Submit LDTE administrative forms digitally
- View submitted forms and their current status
- Generate and print form documents
- Upload supporting documents when required
- Receive reminders for relevant submissions
- Access information and instructions configured by LDTE administrators

### Available Forms

The application currently provides the following forms:

1. **Pertukaran Jadwal Praktikum**
   - Request to exchange a practicum schedule.

2. **Izin Tidak Mengikuti Praktikum**
   - Request for permission to be absent from a practicum.

3. **Surat Keterangan Praktikum**
   - Submit a request for a practicum attendance/participation statement, including supporting evidence when required.

4. **Permohonan Susulan Praktikum**
   - Request a replacement/makeup practicum session.

5. **Peminjaman Peralatan**
   - Request to borrow equipment from LDTE.
   - Supports multiple items and quantities in a single request.

### Administrator

The application also provides an administration interface for managing submitted forms and supporting data.

Administrators can:

- View submitted forms
- Search, sort, and filter submissions
- View submission details
- Update submission statuses
- Manage equipment available for borrowing
- Manage faculty and study program data
- Manage course and practicum data
- Configure application-wide information and form instructions
- Manage form-related templates and LDTE information

The codebase contains dedicated administrative interfaces for equipment, faculties, study programs, courses, and global configuration, in addition to administration pages for individual form types.

## Document Generation

Submitted forms can be converted into printable PDF documents.

PDF generation is handled within the application using Flutter's PDF and printing libraries, with a dedicated PDF worker for generating documents without unnecessarily blocking the main application flow.

The project also includes custom fonts used to reproduce the required document formatting.

## Data & Storage

The application uses **Supabase** as its backend service.

Supabase is used for:

- Authentication
- Remote application data
- Form submissions
- Application configuration
- Reference data such as faculties, study programs, courses, and equipment

The application also uses **Hive CE** for local storage and caching.

A local cache is maintained for relatively static data such as:

- Global configuration
- Faculty and study program information
- Course/practicum information
- Equipment data
- User preferences
- Synchronization timestamps

This allows the application to avoid repeatedly fetching data that has not changed.

## Architecture

At a high level, the application follows this structure:

```text
Flutter Application
│
├── Homepage & Authentication
│
├── Student Interface
│   ├── Pertukaran Jadwal Praktikum
│   ├── Izin Tidak Mengikuti Praktikum
│   ├── Surat Keterangan Praktikum
│   ├── Permohonan Susulan Praktikum
│   └── Peminjaman Peralatan
│
├── Administrator Interface
│   ├── Form Submission Management
│   ├── Equipment Management
│   ├── Faculty Management
│   ├── Study Program Management
│   ├── Course Management
│   └── Global Configuration
│
├── Shared Services
│   ├── API / Supabase
│   ├── State Management
│   ├── Local Cache
│   └── PDF Generation
│
└── Supabase
    ├── Authentication
    └── Application Database
```

## Project Structure

The main application code is organized into several areas:

```text
lib/
├── admin/
│   ├── config.dart
│   ├── daftar_barang.dart
│   ├── fakultas.dart
│   ├── mata_kuliah.dart
│   └── program_studi.dart
│
├── core/
│   ├── api.dart
│   ├── controller.dart
│   ├── db.dart
│   ├── model.dart
│   ├── pdf_worker.dart
│   └── service.dart
│
├── form/
│   ├── izin/
│   ├── peminjaman_peralatan/
│   ├── pertukaran_jadwal_praktikum/
│   └── surat_keterangan_praktikum/
│
├── hive/
├── homepage/
├── misc/
├── susulan_praktikum/
└── main.dart
```

The separation of each form into its own directory makes it possible to develop and maintain individual form workflows independently.

## Technology Stack

| Technology                                            | Purpose                                    |
| ----------------------------------------------------- | ------------------------------------------ |
| [Flutter](https://flutter.dev/)                       | Application framework                      |
| [Dart](https://dart.dev/)                             | Programming language                       |
| [Supabase](https://supabase.com/)                     | Authentication and backend database        |
| [GetX](https://pub.dev/packages/get)                  | State management and application utilities |
| [GoRouter](https://pub.dev/packages/go_router)        | Application routing                        |
| [Hive CE](https://pub.dev/packages/hive_ce)           | Local storage and caching                  |
| [PDF](https://pub.dev/packages/pdf)                   | PDF document generation                    |
| [Printing](https://pub.dev/packages/printing)         | PDF preview and printing                   |
| [Google Fonts](https://pub.dev/packages/google_fonts) | Font management                            |
| [Image Picker](https://pub.dev/packages/image_picker) | Supporting image/document selection        |

## Development

### Requirements

* Flutter SDK
* Dart SDK
* A configured Supabase project
* Android Studio or another Flutter-compatible development environment

The project currently targets Dart SDK `^3.10.7`.

### Getting Started

Clone the repository:

```bash
git clone https://github.com/YutaHitori/eForm-LDTE.git
cd eForm-LDTE
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

For web:

```bash
flutter run -d chrome
```

## Project Background

eForm LDTE was developed as part of a **Praktik Kerja Lapangan (PKL)** project.

The primary objective was to transform several LDTE administrative processes from paper-based/manual workflows into a digital system.

The project was developed independently from the ground up, including:

* Understanding the existing administrative workflows
* Designing the application structure
* Designing and implementing the user interface
* Implementing form workflows
* Connecting the application to the backend
* Implementing local data caching
* Developing PDF document generation
* Building administrative management interfaces
* Testing and refining the application based on feedback

The development process also involved adapting the application based on requirements, direction, and evaluation from the project supervisor.

## Project Status

**Completed / Usable**

The main functionality of eForm LDTE has been implemented and the application is ready to be used for the supported LDTE workflows.

However, because the application only began to be used near the end of the PKL period, long-term evaluation of its usage and effectiveness has not yet been performed.

## Screenshots

> Screenshots will be added here.

## Notes

This repository contains the Flutter application for eForm LDTE.

Backend configuration, database credentials, and other deployment-specific information are intentionally not included in the repository.

## License

This project was developed for LDTE STEI ITB as part of a Praktik Kerja Lapangan (PKL) project.
