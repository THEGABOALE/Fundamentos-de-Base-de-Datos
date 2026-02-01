using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;

namespace RDLC
{
    public partial class Form1 : Form
    {
        private readonly string connectionString =
            @"Data Source=Gabo;Initial Catalog=CompraVentaInventario;Integrated Security=True;TrustServerCertificate=True";

        // Si tu .rdlc está en el proyecto con Build Action = Embedded Resource:
        private readonly string embeddedReportName = "RDLC.Report1.rdlc";
        private readonly string fileReportPath = @"Report1.rdlc";

        // Ajusta si en el RDLC tu DataSet tiene otro nombre (ver "Report Data" -> DataSets)
        private readonly string preferredReportDataSetName = "DataSet1";

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            LoadReport();
        }

        private void LoadReport()
        {
            // CONSULTA: devuelve columnas con NOMBRES EXACTOS que usa tu RDLC
            string sql = @"
                SELECT
                    p.idProducto,
                    p.sku,
                    p.nombre,
                    p.idCategoria,
                    p.idMarca,
                    p.idUMBase,
                    p.controlaLote,
                    p.costoPromedio,
                    p.estado,
                    p.fechaRegistro
                FROM dbo.Producto p
            ";

            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }

                if (dt.Rows.Count == 0)
                {
                    MessageBox.Show("La consulta no devolvió filas. Verifica que la base tenga datos (ejecuta tus scripts de inserts).", "Sin datos", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }

                reportViewer1.ProcessingMode = ProcessingMode.Local;
                reportViewer1.LocalReport.DataSources.Clear();

                bool loaded = false;
                try
                {
                    reportViewer1.LocalReport.ReportEmbeddedResource = embeddedReportName;
                    loaded = true;
                }
                catch
                {
                    loaded = false;
                }

                if (!loaded)
                {
                    if (File.Exists(fileReportPath))
                    {
                        reportViewer1.LocalReport.ReportPath = fileReportPath;
                        loaded = true;
                    }
                    else
                    {
                        string alt = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileReportPath);
                        if (File.Exists(alt))
                        {
                            reportViewer1.LocalReport.ReportPath = alt;
                            loaded = true;
                        }
                    }
                }

                if (!loaded)
                {
                    MessageBox.Show("No se encontró el .rdlc. Verifica 'embeddedReportName' y 'fileReportPath'.", "Reporte no encontrado", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // añadir datasource con el nombre del DataSet que usa el RDLC
                var rds = new ReportDataSource(preferredReportDataSetName, dt);
                reportViewer1.LocalReport.DataSources.Add(rds);

                reportViewer1.RefreshReport();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error cargando el reporte: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
