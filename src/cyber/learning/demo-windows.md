# Implementing DFS for branch offices

A.Datum Corporation有數個關鍵的共用資料夾，必須讓雪梨和多倫多的使用者存取，資料夾一天會被雪梨和多倫多使用者存取數次，但從多倫多存取是從早到晚，為確保使用者在存取檔案時有最佳的體驗，A.Datum已經決定為多倫多的使用者實作DFSR。

---

# Implementing DFS

A.Datum的多倫多辦公室有一台單一伺服器，稱為TOR-SVR1，為了支援分公司員工的需求，你必須在LON-SVR1和TOR-SVR1之間設定DFC複寫名為BranchDocs的共用資料夾，為避免遠端執行備份，在倫敦位置的BranchDocs資料夾會和TOR-SVR1複寫，提供快速存取檔案，集中式備份仍在倫敦維護檔案。

## 1. Install the DFS role on `LON-SVR1` and `TOR-SVR1`

> install-feature.ps1

## 2. Create the BranchDocs DFS Namespace

> new-DfsFolder.ps1

### GUI need manualy add namespace to display / Refresh

## 3. Add the DataFiles folder to the BranchDocs namespace

## 4. Create a folder target for Datafiles on `TOR-SVR1`

## 5. Configure replication for the namespace

---

# Validating the deployment

你現在必須驗證你為多倫多和雪梨地點時做的檔案服務可用性設定可以正常運作。

## 1. Verify DFSR functionality for `TOR-SVR1`