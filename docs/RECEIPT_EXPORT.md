# Receipt PDF export

The previous Save receipt PDF button used Printing.layoutPdf, which opens the system print service. Android now uses ACTION_CREATE_DOCUMENT through the coffee_shop/receipt method channel in MainActivity, letting the customer choose a PDF filename and destination directly. No broad storage permission is requested. The native write runs off the UI thread, returns success only after the stream closes, and distinguishes cancellation from failure. Other platforms use Printing.sharePdf.

The button disables while preparing/saving, logs the underlying exception, and displays useful save/reinstall guidance. A full Android rebuild and installation is required for native channel changes; hot reload cannot add them.

The receipt uses a table that spans pages and repeats its headings, with totals and a page-numbered preview footer. The original single container could exceed a page for large orders. PDF tests cover a delivery receipt and 33 lines (all 11 coffees in three sizes); export tests cover bytes/filename, cancellation, and storage failure.

Reference: https://developer.android.com/training/data-storage/shared/documents-files#create-file

The rebuilt Android export flow was subsequently verified on the owner's phone. The original failure was not captured in device logs, so its exact cause remains unconfirmed. Changes to the native save channel require a full rebuild and installation.
