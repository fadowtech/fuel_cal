import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/AppShell";
import { ScreenHeader } from "@/components/ScreenHeader";
import { FileText, FileSpreadsheet, Calendar, Car, Download } from "lucide-react";

export const Route = createFileRoute("/reports")({
  head: () => ({ meta: [{ title: "Reports — FuelMate" }] }),
  component: ReportsPage,
});

function ReportsPage() {
  const reports = [
    { icon: FileText, title: "Monthly PDF report", sub: "May 2026 summary", tag: "PDF" },
    { icon: FileSpreadsheet, title: "Excel export", sub: "All fuel entries", tag: "XLSX" },
    { icon: Calendar, title: "Yearly summary", sub: "Jan – Dec 2025", tag: "PDF" },
    { icon: Car, title: "Per-vehicle report", sub: "Toyota Innova", tag: "PDF" },
  ];
  return (
    <AppShell>
      <ScreenHeader title="Reports" subtitle="Generate & export" />
      <div className="px-5 pt-4 space-y-3">
        {reports.map((r, i) => (
          <button key={i} className="flex w-full items-center gap-4 rounded-2xl gradient-card p-4 shadow-card text-left">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl gradient-neon text-neon-foreground">
              <r.icon className="h-5 w-5" />
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-2">
                <p className="text-sm font-semibold">{r.title}</p>
                <span className="rounded-full bg-surface px-2 py-0.5 text-[10px] text-muted-foreground">{r.tag}</span>
              </div>
              <p className="text-xs text-muted-foreground">{r.sub}</p>
            </div>
            <Download className="h-5 w-5 text-muted-foreground" />
          </button>
        ))}
      </div>
    </AppShell>
  );
}
