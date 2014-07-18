require 'nokogiri'
require 'open-uri'
require 'csv'
require 'net/http'

# 新建CSV文档
def new_csv(index)
	CSV.open("#{index}.csv", "w") do |csv|
	  csv << ["股票代码", "股票名称", "2014-03-31", "2013-12-31", "2013-09-30", "2013-06-30", "2013-03-31", "2012-12-31"]
	end
end 

# 检测网页是否存在
def valid_url(url)
	url = URI.parse(url)
	req = Net::HTTP.new(url.host, url.port)
	res = req.request_head(url.path)
	return true if res.code == '200'
end

# 抓取数据extract_data
def extract_data(stock_num, index, url)
	# 数据来源为网易股票频道，按报告期的主要财务指标，默认显示为6个季度
	source = Nokogiri::HTML(open(url))
	# 获取股票名称
	name_table = source.search("//h1[@class='name']//a")
	name = name_table[0].text
	# 搜寻所有属于指定css class的值，返回的是一个Array
	data_table = source.search("//table[@class='table_bg001 border_box fund_analys']//td")
	# 查找Array中含有指定文字描述的元素，并返回元素的地址
	i = 0
	j = 0
	while i < data_table.length	
		j = i if data_table[i].text.include?("#{index}")
		i += 1
	end
	# 上一步查找到的元素地址后面的六个元素含有所需数据，将其中的数字部分提取出来
	# 并加入到一个新建的Array中去
	s = ["#{stock_num}", "#{name}"]
	for i in (j+1)..(j+6)
		data = data_table[i].to_s.delete("^0-9")
		data100 = (data.to_i)/100.00
		s << data100
	end
	# 返回数据
	s
end 

######

# 设定财务指标并新建csv文件
index = "速动比率"
new_csv(index)

# 抓取数据并存入csv文件
for i in 600000..600100
	stock_num = i
	url = "http://quotes.money.163.com/f10/zycwzb_#{stock_num},report.html"
	if valid_url(url)
		CSV.open("#{index}.csv", "ab") do |csv|
  		csv << extract_data(stock_num, index, url)
		end
	end
end





