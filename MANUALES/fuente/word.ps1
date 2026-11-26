# Funciones para armar un documento de Word con elementos nativos (estilos, listas, tablas,
# índice, controles de imagen). Las usan manual_usuario.ps1 y manual_tecnico.ps1.

$script:cm = 28.35   # puntos por centímetro

function Iniciar-Documento {
    $script:word = New-Object -ComObject Word.Application
    $script:word.Visible = $false
    $script:word.DisplayAlerts = 0
    $script:doc = $script:word.Documents.Add()
    $script:sel = $script:word.Selection

    $ps = $script:doc.PageSetup
    $ps.PaperSize = 7   # A4
    $ps.TopMargin = 2.5 * $cm; $ps.BottomMargin = 2.5 * $cm
    $ps.LeftMargin = 2.5 * $cm; $ps.RightMargin = 2.5 * $cm

    $negro = -16777216   # color automático
    $normal = $script:doc.Styles.Item(-1)
    $normal.Font.Name = "Calibri"; $normal.Font.Size = 11; $normal.Font.Color = $negro
    $normal.ParagraphFormat.SpaceBefore = 0; $normal.ParagraphFormat.SpaceAfter = 6
    $normal.ParagraphFormat.LineSpacingRule = 5; $normal.ParagraphFormat.LineSpacing = 13.8

    $t1 = $script:doc.Styles.Item(-2)   # Título 1: cada sección empieza en una página nueva
    $t1.Font.Name = "Calibri"; $t1.Font.Size = 18; $t1.Font.Bold = $true; $t1.Font.Color = $negro
    $t1.ParagraphFormat.SpaceBefore = 0; $t1.ParagraphFormat.SpaceAfter = 12
    $t1.ParagraphFormat.PageBreakBefore = $true; $t1.ParagraphFormat.KeepWithNext = $true

    $t2 = $script:doc.Styles.Item(-3)   # Título 2: subtítulos
    $t2.Font.Name = "Calibri"; $t2.Font.Size = 13; $t2.Font.Bold = $true; $t2.Font.Color = $negro
    $t2.ParagraphFormat.SpaceBefore = 12; $t2.ParagraphFormat.SpaceAfter = 4
    $t2.ParagraphFormat.PageBreakBefore = $false; $t2.ParagraphFormat.KeepWithNext = $true

    foreach ($id in @(-20, -21)) {   # estilos del índice
        $s = $script:doc.Styles.Item($id); $s.Font.Name = "Calibri"; $s.Font.Size = 11; $s.Font.Color = $negro
    }

    # Primera hoja en blanco para la carátula
    $script:sel.InsertBreak(7)
    # Hoja de índice
    $script:sel.Font.Size = 18; $script:sel.Font.Bold = $true
    $script:sel.TypeText([char]0x00CD + "ndice")
    $script:sel.TypeParagraph()
    $script:sel.Font.Size = 11; $script:sel.Font.Bold = $false
    $script:indice = $script:doc.TablesOfContents.Add($script:sel.Range, $true, 1, 2)
    $script:sel.EndKey(6) | Out-Null
}

# Escribe texto. **negrita** y `código` se marcan como en Markdown
function Escribir([string]$texto) {
    $partes = [regex]::Split($texto, '(\*\*[^*]+\*\*|`[^`]+`)')
    foreach ($p in $partes) {
        if ($p -eq "") { continue }
        if ($p.StartsWith("**")) {
            $script:sel.Font.Bold = $true; $script:sel.TypeText($p.Substring(2, $p.Length - 4)); $script:sel.Font.Bold = $false
        } elseif ($p.StartsWith('`')) {
            $script:sel.Font.Name = "Consolas"; $script:sel.Font.Size = 10
            $script:sel.TypeText($p.Substring(1, $p.Length - 2))
            $script:sel.Font.Name = "Calibri"; $script:sel.Font.Size = 11
        } else {
            $script:sel.TypeText($p)
        }
    }
}

function Normal { $script:sel.Style = $script:doc.Styles.Item(-1) }

function T1([string]$t) { $script:sel.Style = $script:doc.Styles.Item(-2); $script:sel.TypeText($t); $script:sel.TypeParagraph(); Normal }
function T2([string]$t) { $script:sel.Style = $script:doc.Styles.Item(-3); $script:sel.TypeText($t); $script:sel.TypeParagraph(); Normal }

function P([string]$t) { Normal; Escribir $t; $script:sel.TypeParagraph() }

# Lista con viñetas o numerada (cada lista numerada empieza en 1)
function Lista([string[]]$items, [switch]$Numerada) {
    Normal
    $galeria = 1; if ($Numerada) { $galeria = 2 }
    $plantilla = $script:word.ListGalleries.Item($galeria).ListTemplates.Item(1)
    $script:sel.Range.ListFormat.ApplyListTemplate($plantilla, $false)
    foreach ($i in $items) { Escribir $i; $script:sel.TypeParagraph() }
    $script:sel.Range.ListFormat.RemoveNumbers()
    Normal
}

# Tabla de Word: la primera fila es el encabezado (en negrita y repetida si la tabla sigue en otra página)
function Tabla($filas, [int[]]$anchos = @()) {
    Normal
    $nf = $filas.Count; $nc = $filas[0].Count
    $t = $script:doc.Tables.Add($script:sel.Range, $nf, $nc)
    $t.Borders.Enable = $true
    $t.Range.ParagraphFormat.SpaceAfter = 2
    $t.Range.ParagraphFormat.SpaceBefore = 2
    $t.Range.ParagraphFormat.LineSpacingRule = 0
    $t.Range.Font.Size = 10
    for ($i = 0; $i -lt $nf; $i++) {
        for ($j = 0; $j -lt $nc; $j++) {
            $t.Cell($i + 1, $j + 1).Range.Text = [string]$filas[$i][$j]
        }
    }
    $t.Rows.Item(1).Range.Font.Bold = $true
    $t.Rows.Item(1).HeadingFormat = $true
    $t.Rows.AllowBreakAcrossPages = $false
    $t.PreferredWidthType = 2; $t.PreferredWidth = 100
    if ($anchos.Count -eq $nc) {
        for ($j = 0; $j -lt $nc; $j++) { $c = $t.Columns.Item($j + 1); $c.PreferredWidthType = 2; $c.PreferredWidth = $anchos[$j] }
    }
    $script:sel.EndKey(6) | Out-Null
    $script:sel.TypeParagraph()
}

# Recuadro grande para pegar una foto: tiene un control de imagen de Word (clic → Insertar imagen)
function Foto([string]$descripcion, [double]$altoCm = 9) {
    Normal
    $t = $script:doc.Tables.Add($script:sel.Range, 1, 1)
    $t.Borders.Enable = $true
    $t.PreferredWidthType = 2; $t.PreferredWidth = 100
    $fila = $t.Rows.Item(1); $fila.HeightRule = 1; $fila.Height = $altoCm * $cm   # alto mínimo
    $celda = $t.Cell(1, 1)
    $celda.VerticalAlignment = 1
    $celda.Range.ParagraphFormat.Alignment = 1
    $celda.Range.ParagraphFormat.SpaceAfter = 0
    $r = $celda.Range; $r.MoveEnd(1, -1) | Out-Null
    try { $null = $script:doc.ContentControls.Add(2, $r) } catch { $r.Text = "Pegar foto acá" }
    $script:sel.EndKey(6) | Out-Null
    $script:sel.ParagraphFormat.Alignment = 1
    $script:sel.Font.Italic = $true; $script:sel.Font.Size = 10
    $script:sel.TypeText($descripcion)
    $script:sel.Font.Italic = $false; $script:sel.Font.Size = 11
    $script:sel.TypeParagraph()
    $script:sel.ParagraphFormat.Alignment = 0
}

# Imagen ya hecha (esquemático, PCB, diagramas)
function Imagen([string]$ruta, [double]$anchoCm, [string]$pie) {
    Normal
    $script:sel.ParagraphFormat.Alignment = 1
    $img = $script:sel.InlineShapes.AddPicture($ruta, $false, $true)
    $img.LockAspectRatio = -1
    $img.Width = $anchoCm * $cm
    $script:sel.TypeParagraph()
    $script:sel.Font.Italic = $true; $script:sel.Font.Size = 10
    $script:sel.TypeText($pie)
    $script:sel.Font.Italic = $false; $script:sel.Font.Size = 11
    $script:sel.TypeParagraph()
    $script:sel.ParagraphFormat.Alignment = 0
}

# Fragmento de código en un recuadro
function Codigo([string[]]$lineas) {
    Normal
    $t = $script:doc.Tables.Add($script:sel.Range, 1, 1)
    $t.Borders.Enable = $true
    $t.PreferredWidthType = 2; $t.PreferredWidth = 100
    $r = $t.Cell(1, 1).Range
    $r.Text = ($lineas -join [char]11)   # salto de línea manual dentro de la celda
    $r.Font.Name = "Consolas"; $r.Font.Size = 9
    $r.ParagraphFormat.SpaceAfter = 2; $r.ParagraphFormat.SpaceBefore = 2; $r.ParagraphFormat.LineSpacingRule = 0
    $script:sel.EndKey(6) | Out-Null
    $script:sel.TypeParagraph()
}

function Terminar-Documento([string]$salida, [string]$pdf = "") {
    # Número de página al pie (la carátula sin número)
    $sec = $script:doc.Sections.Item(1)
    $sec.PageSetup.DifferentFirstPageHeaderFooter = $true
    $null = $sec.Footers.Item(1).PageNumbers.Add(1, $false)
    $script:doc.Repaginate()
    $script:indice.Update()
    $script:doc.SaveAs2([System.IO.Path]::GetFullPath($salida), 16)
    if ($pdf -ne "") { $script:doc.ExportAsFixedFormat([System.IO.Path]::GetFullPath($pdf), 17) }
    $script:doc.Close($false)
    $script:word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($script:word) | Out-Null
}
