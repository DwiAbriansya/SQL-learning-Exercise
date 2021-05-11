-- The Risk Team want to know the amount of customer who is a fraud
SELECT count(1) as jumlah_penipu
FROM rakamin_customer
WHERE penipu = 1

-- Management Team want to know the where all the customers come from
SELECT DISTINCT kota
FROM rakamin_customer_address

-- Marketing Team want to run a campaign for customer who are already working
-- Assuming customer with age above 22 already have a job
-- Make sure the customer are not a fraud and already confirm their phone number
SELECT id_pelanggan, nama, email, telepon
FROM rakamin_customer
WHERE umur > 22 AND penipu = 0 AND konfirmasi_telepon = 1

-- Engineering Team recently updated rakamin_order table schema
-- Display the 5 newest transaction from the updated table
SELECT *
FROM rakamin_order
ORDER BY tanggal_pembelian DESC
LIMIT 5

-- Marketing Team want to run birthday celebration campaign
-- Extract the amount of customer based on their birthday's month
-- Sort it from the greatest
SELECT bulan_lahir, count(id_pelanggan) as Jumlah_customer
FROM rakamin_customer
WHERE bulan_lahir not NULL
GROUP BY bulan_lahir
ORDER BY Jumlah_customer DESC

-- One of our merchants, KFC Depok, wants to open a new branch.
-- Therefore they ask us for insights to see which areas have the most potential in
-- outside the city of Depok.
SELECT rca.kota, rca.alamat, sum(ro.kuantitas*ro.harga) as Total_Penjualan
FROM rakamin_customer_address rca
JOIN rakamin_order ro ON ro.id_pelanggan = rca.id_pelanggan
WHERE kota is NOT "Depok"
GROUP BY kota, alamat
ORDER BY Total_Penjualan DESC

-- Management want to give a cashback for customer who use an email from roketmail domain.
-- Make sure they are not a fraud
SELECT rc.id_pelanggan, rc.nama, rc.telepon, rc.email, sum(ro.harga*ro.kuantitas*1.1) as TPV
FROM rakamin_customer rc
JOIN rakamin_order ro ON rc.id_pelanggan = ro.id_pelanggan
WHERE email LIKE "%roketmail.com" AND penipu = 0
GROUP BY 1,2,3,4


-- Management wants to know the distribution of payment methods in each city.
-- pivot metode_bayar column into each value, then group them by city
-- and sort them by cashless_percentage
WITH 
metode_bayar_kota AS
(
SELECT 
	rca.kota,
	count(CASE WHEN ro.metode_bayar = "cash" then 1 else NULL END) Cash,
	count(CASE WHEN ro.metode_bayar = "ovo" then 1 else NULL END) OVO,
	count(CASE WHEN ro.metode_bayar = "gopay" then 1 else NULL END) GOPAY,
	count(CASE WHEN ro.metode_bayar = "shopeepay" then 1 else NULL END) Shopeepay,
	count(CASE WHEN ro.metode_bayar = "link aja" then 1 else NULL END) Linkaja,
	count(CASE WHEN ro.metode_bayar = "dana" then 1 else NULL END) DANA,
	count(CASE WHEN ro.bayar_cash = 0 then 1 else NULL END) total_pelanggan_cashless,
	count(ro.id_pelanggan) total_pelanggan
FROM rakamin_order ro
JOIN rakamin_customer_address rca ON ro.id_pelanggan = rca.id_pelanggan
GROUP BY 1
)
SELECT *, (total_pelanggan_cashless*1.0/total_pelanggan)*100 as cashless_percentage
FROM metode_bayar_kota
ORDER BY cashless_percentage DESC