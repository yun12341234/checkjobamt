WITH PROFIT AS (
    SELECT
        a.jobno,
        b.JobType,
        b.StatusCode,
        a.itemcode,
        a.description,
        a.AMT AS EachSalesamount,
        a.Costamt AS Eachcostamount,
        SUM(a.AMT) OVER (PARTITION BY a.jobno) AS Salesamount,
        SUM(a.COSTAMT) OVER (PARTITION BY a.jobno) AS CostAMT,
        SUM(a.AMT) OVER (PARTITION BY a.jobno) - SUM(a.COSTAMT) OVER (PARTITION BY a.jobno) AS profit,
        a.CostApproveFlag,
        a.SalesApproveFlag
    FROM
        jmjm2 AS a
    LEFT JOIN
        jmjm1 AS b ON a.jobno = b.JobNo
),
ACCOUNT AS (
    SELECT
        a.jobno,
        a.ItemCode,
        b.InvoiceNo,
        SUM(a.Amt) OVER (PARTITION BY a.jobno) AS salesinvoiceamt,
        SUM(a.CostAmt) OVER (PARTITION BY a.jobno) AS costamt,
        b.WithHoldingTaxAmt,
        SUM(a.VatAmt) OVER (PARTITION BY a.jobno) AS vatamt
    FROM
        ivcr2 AS a
    LEFT JOIN
        ivcr1 AS b ON a.jobno = b.jobno
),
overview AS (
    SELECT
        DISTINCT PROFIT.JobNo,
        ACCOUNT.InvoiceNo,
        PROFIT.JobType,
        PROFIT.StatusCode,
        PROFIT.Salesamount,
        PROFIT.profit,
        ACCOUNT.salesinvoiceamt,
        ACCOUNT.costamt,
        ACCOUNT.vatamt,
        ACCOUNT.WithHoldingTaxAmt,
        ACCOUNT.salesinvoiceamt - ACCOUNT.costamt AS ACCOUNTPROFIT,
        ACCOUNT.salesinvoiceamt + ACCOUNT.vatamt + ACCOUNT.WithHoldingTaxAmt AS totalinvoiceamt,
        PROFIT.Salesamount - ACCOUNT.salesinvoiceamt AS diff
    FROM
        PROFIT
    LEFT JOIN
        ACCOUNT ON PROFIT.jobno = ACCOUNT.JobNo
)
SELECT
    LEFT(overview.jobno, 2) AS job_type,
    COUNT(CASE WHEN overview.salesinvoiceamt IS NULL THEN 1 ELSE NULL END) AS null_invoice_count
FROM
    overview
GROUP BY
    LEFT(overview.jobno, 2);
