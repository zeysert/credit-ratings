
using Pkg;
Pkg.add("DataFrames");

using DataFrames
using Dates
using Plots
using LinearAlgebra

using Printf
Base.show( io::IO, x::Float64) = @printf(io, "%0.4f", x)

raw_data = readtable("data.csv")
head(raw_data)

data = dropmissing(raw_data)
head(data)

ticker = unique(data[:1])
ticker_name = unique(data[:6])

all = DataFrame(datadate=0)
for itr in enumerate(ticker)
#     println(itr[2])
    temp1 = data[data[:1].==itr[2],:][2:3]
    all=join(all, temp1, on= :datadate, kind= :outer)
end

real_all = all[2:end,:]
sort!(real_all);
head(real_all)

data=DataFrame()
ratingcount=zeros(22)
for j in 2:size(real_all)[2]
    temp=[]
    for k in 1:size(real_all)[1]
        if ismissing(real_all[j][k])
            append!(temp,-2)
        elseif real_all[j][k]=="AAA"
            append!(temp,23)
            ratingcount[22]+=1
        elseif real_all[j][k]=="AA+"
            append!(temp,22)
            ratingcount[21]+=1
        elseif real_all[j][k]=="AA"
            append!(temp,21)
            ratingcount[20]+=1
        elseif real_all[j][k]=="AA-"
            append!(temp,20)
            ratingcount[19]+=1
        elseif real_all[j][k]=="A+"
            append!(temp,19)
            ratingcount[18]+=1
        elseif real_all[j][k]=="A"
            append!(temp,18)
            ratingcount[17]+=1
        elseif real_all[j][k]=="A-"
            append!(temp,17)
            ratingcount[16]+=1
        elseif real_all[j][k]=="BBB+"
            append!(temp,16)
            ratingcount[15]+=1
        elseif real_all[j][k]=="BBB"
            append!(temp,15)
            ratingcount[14]+=1
        elseif real_all[j][k]=="BBB-"
            append!(temp,14)
            ratingcount[13]+=1
        elseif real_all[j][k]=="BB+"
            append!(temp,13)
            ratingcount[12]+=1
        elseif real_all[j][k]=="BB"
            append!(temp,12)
            ratingcount[11]+=1
        elseif real_all[j][k]=="BB-"
            append!(temp,11)
            ratingcount[10]+=1
        elseif real_all[j][k]=="B+"
            append!(temp,10)
            ratingcount[9]+=1
        elseif real_all[j][k]=="B"
            append!(temp,9)
            ratingcount[8]+=1
        elseif real_all[j][k]=="B-"
            append!(temp,8)
            ratingcount[7]+=1
        elseif real_all[j][k]=="CCC+"
            append!(temp,7)
            ratingcount[6]+=1
        elseif real_all[j][k]=="CCC"
            append!(temp,6)
            ratingcount[5]+=1
        elseif real_all[j][k]=="CCC-"
            append!(temp,5)
            ratingcount[4]+=1
        elseif real_all[j][k]=="CC"
            append!(temp,4)
            ratingcount[3]+=1
        elseif real_all[j][k]=="C"
            append!(temp,3)
            ratingcount[2]+=1
        elseif real_all[j][k]=="SD"
            append!(temp,2)
            ratingcount[1]+=1
        elseif real_all[j][k]=="D"
            append!(temp,2)
            ratingcount[1]+=1
        elseif real_all[j][k]=="N.M."
            append!(temp,0)    
        else
            append!(temp,0)
        end
    end
    data=hcat(data,temp)
end

ref_list = Dict("AAA"=>23,"AA+"=>22,"AA"=>21,"AA-"=>20,"A+"=>19,"A"=>18,"A-"=>17,
                "BBB+"=>16,"BBB"=>15,"BBB-"=>14,"BB+"=>13,"BB"=>12,"BB-"=>11,"B+"=>10,"B"=>9,"B-"=>8,
                "CCC+"=>7,"CCC"=>6,"CCC-"=>5,"CC"=>4,"C"=>3,"D"=>2,
                "NM"=>0,"missing"=>-2)
sort(ref_list)
all_ticks = DataFrame(ticker=ticker, tickername=ticker_name);

#creating the list of names of rating
sortlist = sort(collect(zip(values(ref_list),keys(ref_list))))
ratinglist = []
for i in 3:length(sortlist)
    ratinglist = vcat(ratinglist, sortlist[i][2])
end

ratingcounter = DataFrame(ratinglist = ratinglist, ratingcount=ratingcount)
sort(ratingcounter, :ratingcount, rev=true)

plot(ratingcounter.ratingcount)

timeframe = DataFrame(Date=[])
for i in 1:size(real_all)[1]
    timeframe = vcat(timeframe, Dates.DateTime(string(real_all[i,1]),"yyyymmdd"))
end
timeframe = timeframe[2:end];

size(data)

plot()
start = 1
en_d = 3
plot!([data[i] for i in start:en_d], label = [ticker[k] for k in start:en_d])

#plot using tick
wantick = ["AIR","4165A","AMESQ"]
ranges = []
for i in wantick
    append!(ranges, findall(all_ticks.tickername.==i))
end

plot()
plot!(timeframe,[data[i] for i in ranges],label=[all_ticks.tickername[k] for k in ranges])


sing_mult_notch=DataFrame(single=[],multi=[])
sing_percentage=[]
mult_percentage=[]
for j in 1:size(data)[2]
    notch=[0,0]
    for k in 1:size(data)[1]-1
        if abs(data[k,j]-data[k+1,j])==1
            if data[k,j]!=-1
                notch[1] = notch[1]+1
            end
        elseif abs(data[k,j]-data[k+1,j])>1
            if data[k,j]!=-1
                notch[2] =notch[2]+1
            end            
        end
    end
    push!(sing_mult_notch,notch)
    append!(sing_percentage,notch[1]/sum(notch))
    append!(mult_percentage,notch[2]/sum(notch))
end
sing_mult_notch=hcat(sing_mult_notch,sing_percentage)
sing_mult_notch=hcat(sing_mult_notch,mult_percentage)
sing_mult_notch=hcat(sing_mult_notch,ticker_name)
rename!(sing_mult_notch,:x1,:single_percentage)
rename!(sing_mult_notch,:x1_1,:multi_percentage)
rename!(sing_mult_notch,:x1_2,:tickername)
println("single notch percentage: ",sum(sing_mult_notch[1])/(sum(sing_mult_notch[1])+sum(sing_mult_notch[2])))
println("multi  notch percentage: ",1-sum(sing_mult_notch[1])/(sum(sing_mult_notch[1])+sum(sing_mult_notch[2])))

#dataframe of single_multi_notch percentage
head(sing_mult_notch)

#sorted by single notch percentage
sort(sing_mult_notch, :single_percentage, rev=true)

#sorted by multi notch percentage
sort(sing_mult_notch, :multi_percentage, rev=true)

#number of total single notch and multi notch changes 
println("single: ",sum(sing_mult_notch[1]),"\nmulti : ",sum(sing_mult_notch[2]))

#Checking the size of data for creating the nested for loop to calculate transition matrix
size(data)

trans=zeros(22,22)
for j in 1:size(data)[2]
    for k in 1:size(data)[1]-1
        if (data[k,j]>0) && (data[k+1,j]>0)
            trans[data[k,j]-1,data[k+1,j]-1]=trans[data[k,j]-1,data[k+1,j]-1]+1
        end
    end
end
transframe=DataFrame(trans)
names!(transframe, [Symbol("$i") for i in ratinglist])

trans2=zeros(22,22)
for j in 1:22
    trans2[j,:]=trans[j,:]/sum(trans[j,:])
end
transframe2=DataFrame(trans2)
names!(transframe2, [Symbol("$i") for i in ratinglist])

transum=[]
singsum=[]
for j in 1:size(trans2)[1]
    if j==1
        tempsum=1-(trans2[j,j]+trans2[j,j+1])
        tempsum2=trans2[j,j+1]
    elseif j==size(trans2)[1]
        tempsum=1-(trans2[j,j]+trans2[j,j-1])
        tempsum2=trans2[j,j-1]
    else
        tempsum=1-(trans2[j,j]+trans2[j,j+1]+trans2[j,j-1])
        tempsum2=trans2[j,j+1]+trans2[j,j-1]
    end
    append!(transum,tempsum)
    append!(singsum,tempsum2)
end

DataFrame(ratinglist=ratinglist,multiprob=transum,singprob=singsum)

#migration of 100 steps starting from AAA and stationary distribution
initial=zeros(22)
initial[22]=1
migration=transpose(initial)*(trans2^100)
M = trans2 - one(trans2)
M[:,22] = ones(22)
stationary=transpose(initial)*inv(M)
DataFrame(ratinglist=ratinglist,migration_100=transpose(migration),stationary=transpose(stationary))


#group up A B C D 
basket=zeros(4,4)
for j in enumerate([1,2:6,7:15,16:22])
    for k in enumerate([1,2:6,7:15,16:22])
        basket[j[1],k[1]]=sum(trans[j[2],k[2]])
    end
    basket[j[1],:]=basket[j[1],:]/sum(basket[j[1],:])
end

bask=DataFrame(basket) #D C B A
names!(bask,[:D,:C,:B,:A])

raw_data = readtable("raw_data.csv");
size(raw_data)

data = raw_data[raw_data.splticrm .!== missing,:];
size(data)

size(unique(data.gvkey),1)

by(data, :gvkey, size)

selected_index = []
for subdf in groupby(data, :gvkey)
    if size(subdf,1) === 242
        push!(selected_index,subdf.gvkey[1])
    end
end
size(selected_index,1)

selected_data = data[data.gvkey .=== selected_index[1],:]
for i in 2:size(selected_index,1)
    temp = data[data.gvkey .=== selected_index[i],:]
    selected_data = vcat(temp, selected_data)
end
size(selected_data,1)

unique(selected_data.datadate)

unique(selected_data.splticrm)

sort!(selected_data, :datadate)

sort!(selected_data, :splticrm)

rating_string = selected_data.splticrm;
rating_float = Array{Int64}(undef,(size(rating_string,1),1))
for i in 1:size(rating_string,1)
    if rating_string[i] == "AAA"
        rating_float[i] = 21
    elseif rating_string[i] == "AA+"
        rating_float[i] = 20
    elseif rating_string[i] == "AA"
        rating_float[i] = 19
    elseif rating_string[i] == "AA-"
        rating_float[i] = 18
    elseif rating_string[i] == "A+"
        rating_float[i] = 17
    elseif rating_string[i] == "A"
        rating_float[i] = 16
    elseif rating_string[i] == "A-"
        rating_float[i] = 15
    elseif rating_string[i] == "BBB+"
        rating_float[i] = 14
    elseif rating_string[i] == "BBB"
        rating_float[i] = 13
    elseif rating_string[i] == "BBB-"
        rating_float[i] = 12
    elseif rating_string[i] == "BB+"
        rating_float[i] = 11
    elseif rating_string[i] == "BB"
        rating_float[i] = 10
    elseif rating_string[i] == "BB-"
        rating_float[i] = 9
    elseif rating_string[i] == "B+"
        rating_float[i] = 8
    elseif rating_string[i] == "B"
        rating_float[i] = 7
    elseif rating_string[i] == "B-"
        rating_float[i] = 6
    elseif rating_string[i] == "CCC+"
        rating_float[i] = 5
    elseif rating_string[i] == "CCC"
        rating_float[i] = 4
    elseif rating_string[i] == "CCC-"
        rating_float[i] = 3
    elseif rating_string[i] == "CC"
        rating_float[i] = 2
    elseif rating_string[i] == "D" || rating_string[i] == "SD"
        rating_float[i] = 1 
    end
end
rating_float

delete!(selected_data,:splticrm)

rating_float = convert(DataFrame, rating_float);
rename!(rating_float, :x1 => :rating)

selected_data = hcat(selected_data, rating_float)

sort!(selected_data,:tic)

# Select American Airline as the example
AAL = DataFrame(selected_data[selected_data.tic .=== "AAL",:]);
sort!(AAL,:datadate)
date = trunc.(Int, AAL.datadate / 10000)
plot(date, AAL.rating, label = "Rating", title = "American Airline Rating Change")

savefig("AAL_rating.png")

part1_transition_df_with_year_transition = DataFrame(company = String[], singlenotch = Int[], multinotch = Int[], perctmultinotch = Float64[]);
part1_transition_df_without_year_transition = DataFrame(company = String[], singlenotch = Int[], multinotch = Int[], perctmultinotch = Float64[]);
multiple_notch_counter = 0;
single_notch_counter = 0;

for subgroup in groupby(selected_data, :gvkey)
    subgroup = sort(subgroup,:datadate)
    temp_rating = subgroup.rating
    previous = temp_rating[1]
    multiple_notch_counter = 0
    single_notch_counter = 0
    for i in 2:size(temp_rating,1)
        if abs(temp_rating[i] - previous) > 1
            multiple_notch_counter = multiple_notch_counter + 1
        elseif abs(temp_rating[i] - previous) == 1
            single_notch_counter = single_notch_counter + 1
        end
        previous = temp_rating[i]
    end
    perct = multiple_notch_counter / (single_notch_counter + multiple_notch_counter)
    name = subgroup.tic[1]
    push!(part1_transition_df_with_year_transition, [name, single_notch_counter, multiple_notch_counter, perct])
end
part1_transition_df_with_year_transition

println(sum(part1_transition_df_with_year_transition[:,2]))
println(sum(part1_transition_df_with_year_transition[:,3]))

part2_data = selected_data;
temp_year = trunc.(Int, (part2_data.datadate ./ 10000));
year = DataFrame();
year = hcat(year, temp_year);
rename!(year, :x1 => :year);
part2_data = hcat(part2_data, year)

for subgroup in groupby(part2_data, :gvkey)
    subgroup = sort(subgroup,:datadate)
    temp_rating = subgroup.rating
    temp_year = subgroup.year
    previous = temp_rating[1]
    previous_year = temp_year[1]
    multiple_notch_counter = 0
    single_notch_counter = 0
    for i in 2:size(temp_rating,1)
        if abs(temp_rating[i] - previous) > 1 && temp_year[i] == previous_year
            multiple_notch_counter = multiple_notch_counter + 1
        elseif abs(temp_rating[i] - previous) == 1 && temp_year[i] == previous_year
            single_notch_counter = single_notch_counter + 1
        end
        previous = temp_rating[i]
        previous_year = temp_year[i]
    end
    perct = multiple_notch_counter / (single_notch_counter + multiple_notch_counter)
    name = subgroup.tic[1]
    push!(part1_transition_df_without_year_transition, [name, single_notch_counter, multiple_notch_counter, perct])
end
part1_transition_df_without_year_transition

println(sum(part1_transition_df_without_year_transition[:,2]))
println(sum(part1_transition_df_without_year_transition[:,3]))

part2_transition_df_without_year_transition = DataFrame(year = Int[1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017], singlenotch = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], multinotch = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], perctmultinotch = Float64[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);
part2_transition_df_with_year_transition = DataFrame(year = Int[1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017], singlenotch = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], multinotch = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], perctmultinotch = Float64[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);
overtime_multinotch_counter = 0;
overtime_singlenotch_counter = 0;

# Still use tic as the separating factor, then slowly accumulate the counter
for subgroup in groupby(part2_data, :gvkey)
    subgroup = sort(subgroup,:datadate)
    temp_data = DataFrame(subgroup)
    counter = 1
    for subtime in groupby(temp_data, :year)
        temp_rating = subtime.rating
        previous = temp_rating[1]
        overtime_multinotch_counter = 0
        overtime_singlenotch_counter = 0
        for i in 2:size(temp_rating,1)
            if abs(temp_rating[i] - previous) > 1
                overtime_multinotch_counter = overtime_multinotch_counter + 1
            elseif abs(temp_rating[i] - previous) == 1
                overtime_singlenotch_counter = overtime_singlenotch_counter + 1
            end
            previous = temp_rating[i]
        end
        part2_transition_df_without_year_transition[counter,2] = part2_transition_df_without_year_transition[counter,2] + overtime_singlenotch_counter
        part2_transition_df_without_year_transition[counter,3] = part2_transition_df_without_year_transition[counter,3] + overtime_multinotch_counter
        counter = counter + 1
    end
end
part2_transition_df_without_year_transition.perctmultinotch = part2_transition_df_without_year_transition.multinotch ./ (part2_transition_df_without_year_transition.multinotch + part2_transition_df_without_year_transition.singlenotch)
part2_transition_df_without_year_transition

println(sum(part2_transition_df_without_year_transition[:,2]))
println(sum(part2_transition_df_without_year_transition[:,3]))

# Testing ground 
for subgroup in groupby(part2_data, :gvkey)
    subgroup = sort(subgroup,:datadate)
    A = subgroup[subgroup.year .=== 2017,:]
    println(A)
    break
end

for subgroup in groupby(part2_data, :gvkey)
    subgroup = sort(subgroup,:datadate)
    temp_data = DataFrame(subgroup)
    counter = 1
    init_flag = 0
    previous_year = 0
    for subtime in groupby(temp_data, :year)
        temp_rating = subtime.rating
        previous = temp_rating[1]
        overtime_multinotch_counter = 0
        overtime_singlenotch_counter = 0
        
        if init_flag == 0
            previous_year = temp_rating[end]
        elseif init_flag == 1
            if abs(previous - previous_year) > 1
                overtime_multinotch_counter = overtime_multinotch_counter + 1
            elseif abs(previous - previous_year) == 1
                overtime_singlenotch_counter = overtime_singlenotch_counter + 1
            end
            previous_year = temp_rating[end]
        end
            
        for i in 2:size(temp_rating,1)
            if abs(temp_rating[i] - previous) > 1
                overtime_multinotch_counter = overtime_multinotch_counter + 1
            elseif abs(temp_rating[i] - previous) == 1
                overtime_singlenotch_counter = overtime_singlenotch_counter + 1
            end
            previous = temp_rating[i]
        end
        part2_transition_df_with_year_transition[counter,2] = part2_transition_df_with_year_transition[counter,2] + overtime_singlenotch_counter
        part2_transition_df_with_year_transition[counter,3] = part2_transition_df_with_year_transition[counter,3] + overtime_multinotch_counter
        counter = counter + 1
        init_flag = 1
    end
end
part2_transition_df_with_year_transition.perctmultinotch = part2_transition_df_with_year_transition.multinotch ./ (part2_transition_df_with_year_transition.multinotch + part2_transition_df_with_year_transition.singlenotch)
part2_transition_df_with_year_transition

println(sum(part2_transition_df_with_year_transition[:,2]))
println(sum(part2_transition_df_with_year_transition[:,3]))

transition_matrix_array = [];

transition_data = selected_data;
temp_month = trunc.(Int, (transition_data.datadate - (trunc.(Int, (transition_data.datadate ./ 10000)) * 10000)) ./ 100);
month = DataFrame();
month = hcat(year, temp_month);
rename!(month, :x1 => :month);
transition_data = hcat(transition_data, month)

# Storing data into a total transition matrix just in case
total_transition_matrix = DataFrame()
# A quick creation of transition matrix using for loop
for i in 1:21
    temp = Array([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
    total_transition_matrix = hcat(total_transition_matrix, temp)
end
rename!(total_transition_matrix, Dict(:x1 => Symbol("D/SD"), :x1_1 => Symbol("CC"), :x1_2 => Symbol("CCC-"), :x1_3 => Symbol("CCC"), :x1_4 => Symbol("CCC+"), :x1_5 => Symbol("B-"), :x1_6 => Symbol("B"), :x1_7 => Symbol("B+"), :x1_8 => Symbol("BB-"), :x1_9 => Symbol("BB"), :x1_10 => Symbol("BB+"), :x1_11 => Symbol("BBB-"), :x1_12 => Symbol("BBB"), :x1_13 => Symbol("BBB+"), :x1_14 => Symbol("A-"), :x1_15 => Symbol("A"), :x1_16 => Symbol("A+"), :x1_17 => Symbol("AA-"), :x1_18 => Symbol("AA"), :x1_19 => Symbol("AA+"), :x1_20 => Symbol("AAA")));

summation = 0
sort!(transition_data,:datadate)
for subtime in groupby(transition_data, :year)
    subtime = sort(subtime, :datadate)
    temp_data = DataFrame(subtime)
    
    transition_matrix = DataFrame()
    for i in 1:21
        temp = Array([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
        transition_matrix = hcat(transition_matrix, temp)
    end
    rename!(transition_matrix, Dict(:x1 => Symbol("D/SD"), :x1_1 => Symbol("CC"), :x1_2 => Symbol("CCC-"), :x1_3 => Symbol("CCC"), :x1_4 => Symbol("CCC+"), :x1_5 => Symbol("B-"), :x1_6 => Symbol("B"), :x1_7 => Symbol("B+"), :x1_8 => Symbol("BB-"), :x1_9 => Symbol("BB"), :x1_10 => Symbol("BB+"), :x1_11 => Symbol("BBB-"), :x1_12 => Symbol("BBB"), :x1_13 => Symbol("BBB+"), :x1_14 => Symbol("A-"), :x1_15 => Symbol("A"), :x1_16 => Symbol("A+"), :x1_17 => Symbol("AA-"), :x1_18 => Symbol("AA"), :x1_19 => Symbol("AA+"), :x1_20 => Symbol("AAA")))
    for subgroup in groupby(temp_data, :gvkey)
        temp_rating = subgroup.rating
        previous = temp_rating[1]
        
        for i in 2:size(temp_rating,1)
            transition_matrix[previous,temp_rating[i]] += 1
            total_transition_matrix[previous,temp_rating[i]] += 1
            previous = temp_rating[i]
        end
    end
    
    # Add to the transition_matrix_array
    push!(transition_matrix_array, transition_matrix) 
end
size(transition_matrix_array,1)

total_transition_matrix

transition_matrix_array[7]

# Testing ground
result = 0
transition = []
for i in 1:21
    for row in 1:size(transition_matrix_array[i],1)
        for column in 1:size(transition_matrix_array[i],1)
            if row != column
                result += transition_matrix_array[i][row,column]
            end
        end
    end
    push!(transition, result)
    result = 0
end
transition

total_transition_probability_matrix = DataFrame(x1 = [], x1_1 = [], x1_2 = [], x1_3 = [], x1_4 = [], x1_5 = [], x1_6 = [], x1_7 = [], x1_8 = [], x1_9 = [], x1_10 = [], x1_11 = [], x1_12 = [], x1_13 = [], x1_14 = [], x1_15 = [], x1_16 = [], x1_17 = [], x1_18 = [], x1_19 = [], x1_20 = []);
rename!(total_transition_probability_matrix, Dict(:x1 => Symbol("D/SD"), :x1_1 => Symbol("CC"), :x1_2 => Symbol("CCC-"), :x1_3 => Symbol("CCC"), :x1_4 => Symbol("CCC+"), :x1_5 => Symbol("B-"), :x1_6 => Symbol("B"), :x1_7 => Symbol("B+"), :x1_8 => Symbol("BB-"), :x1_9 => Symbol("BB"), :x1_10 => Symbol("BB+"), :x1_11 => Symbol("BBB-"), :x1_12 => Symbol("BBB"), :x1_13 => Symbol("BBB+"), :x1_14 => Symbol("A-"), :x1_15 => Symbol("A"), :x1_16 => Symbol("A+"), :x1_17 => Symbol("AA-"), :x1_18 => Symbol("AA"), :x1_19 => Symbol("AA+"), :x1_20 => Symbol("AAA")));
for row = 1:size(total_transition_matrix,1)
    temp_row = convert(Array, total_transition_matrix[row,:]) / sum(convert(Array, total_transition_matrix[row,:]))
    push!(total_transition_probability_matrix, temp_row)
end
total_transition_probability_matrix

transition_probability_matrix_array = []
for year = 1:size(transition_matrix_array,1)
    temp_transition_probability_matrix = DataFrame(x1 = [], x1_1 = [], x1_2 = [], x1_3 = [], x1_4 = [], x1_5 = [], x1_6 = [], x1_7 = [], x1_8 = [], x1_9 = [], x1_10 = [], x1_11 = [], x1_12 = [], x1_13 = [], x1_14 = [], x1_15 = [], x1_16 = [], x1_17 = [], x1_18 = [], x1_19 = [], x1_20 = []);
    rename!(temp_transition_probability_matrix, Dict(:x1 => Symbol("D/SD"), :x1_1 => Symbol("CC"), :x1_2 => Symbol("CCC-"), :x1_3 => Symbol("CCC"), :x1_4 => Symbol("CCC+"), :x1_5 => Symbol("B-"), :x1_6 => Symbol("B"), :x1_7 => Symbol("B+"), :x1_8 => Symbol("BB-"), :x1_9 => Symbol("BB"), :x1_10 => Symbol("BB+"), :x1_11 => Symbol("BBB-"), :x1_12 => Symbol("BBB"), :x1_13 => Symbol("BBB+"), :x1_14 => Symbol("A-"), :x1_15 => Symbol("A"), :x1_16 => Symbol("A+"), :x1_17 => Symbol("AA-"), :x1_18 => Symbol("AA"), :x1_19 => Symbol("AA+"), :x1_20 => Symbol("AAA")));
    for row = 1:size(transition_matrix_array[year],1)
        temp_row = convert(Array, transition_matrix_array[year][row,:]) / sum(convert(Array, transition_matrix_array[year][row,:]))
        if sum(convert(Array, transition_matrix_array[year][row,:])) == 0
            temp_row = Array([0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000])
        end
        push!(temp_transition_probability_matrix, temp_row)
    end
    push!(transition_probability_matrix_array, temp_transition_probability_matrix)
end

transition_probability_matrix_array[6]

M = convert(Array, total_transition_probability_matrix) - Matrix{Float64}(I, 21, 21);
M[:,1] = ones(21);
stationary_distribution = DataFrame([1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] * inv(M))
rename!(stationary_distribution, Dict(:x1 => Symbol("D/SD"), :x2 => Symbol("CC"), :x3 => Symbol("CCC-"), :x4 => Symbol("CCC"), :x5 => Symbol("CCC+"), :x6 => Symbol("B-"), :x7 => Symbol("B"), :x8 => Symbol("B+"), :x9 => Symbol("BB-"), :x10 => Symbol("BB"), :x11 => Symbol("BB+"), :x12 => Symbol("BBB-"), :x13 => Symbol("BBB"), :x14 => Symbol("BBB+"), :x15 => Symbol("A-"), :x16 => Symbol("A"), :x17 => Symbol("A+"), :x18 => Symbol("AA-"), :x19 => Symbol("AA"), :x20 => Symbol("AA+"), :x21 => Symbol("AAA")))

raw_data = readtable("data.csv");
data = dropmissing(raw_data);

sector = unique(data.gsector)
print("Number of Unique Sector: ", size(sector, 1), "\n")
print("Unique Sector: ", "\n", sort(sector))

sector_10 = data[data[:4] .== 10,:]
sector_15 = data[data[:4] .== 15,:]
sector_20 = data[data[:4] .== 20,:]
sector_25 = data[data[:4] .== 25,:]
sector_30 = data[data[:4] .== 30,:]
sector_35 = data[data[:4] .== 35,:]
sector_40 = data[data[:4] .== 40,:]
sector_45 = data[data[:4] .== 45,:]
sector_50 = data[data[:4] .== 50,:]
sector_55 = data[data[:4] .== 55,:]
sector_60 = data[data[:4] .== 60,:]

sector_dict = Dict("sector_10"=>sector_10,"sector_15"=>sector_15,"sector_20"=>sector_20,"sector_25"=>sector_25,"sector_30"=>sector_30,"sector_35"=>sector_35,"sector_40"=>sector_40,"sector_45"=>sector_45,"sector_50"=>sector_50,"sector_55"=>sector_55,"sector_60"=>sector_60)

head(sector_dict["sector_60"])

sector_data_dict = Dict()
for sector in ["sector_10","sector_15","sector_20","sector_25", "sector_30","sector_35","sector_40", "sector_45", "sector_50","sector_55","sector_60"]
    sector_data = sector_dict[sector]
    #take out the gvkey
    gvkey=unique(sector_data[:1])    
    #join all companies into dataframe
    all_data=DataFrame(datadate=0)
    for itr in enumerate(gvkey)
        #println(itr[2])
        temp1=sector_data[sector_data[:1].==itr[2],:][2:3]
        all_data=join(all_data,temp1,on= :datadate, kind= :outer,makeunique = true)
    end
    key = sector*"_data"
    sector_data_dict[key] = all_data[2:end,:]
    colnames = vcat(["datadate"],gvkey)
    names!(sector_data_dict[key],Symbol.(colnames))
end

head(sector_data_dict["sector_60_data"])

numerical_data_dict = Dict()
for sector in ["sector_10","sector_15","sector_20","sector_25", "sector_30","sector_35","sector_40", "sector_45", "sector_50","sector_55","sector_60"]
    key = sector*"_data"
    sector_data = sector_data_dict[key]
    data=DataFrame()
    for j in 2:size(sector_data)[2]
        temp=[]
        for k in 1:size(sector_data)[1]
            if ismissing(sector_data[j][k])
                append!(temp,-2)
            elseif sector_data[j][k]=="AAA"
                append!(temp,23)
            elseif sector_data[j][k]=="AA+"
                append!(temp,22)
            elseif sector_data[j][k]=="AA"
                append!(temp,21)
            elseif sector_data[j][k]=="AA-"
                append!(temp,20)
            elseif sector_data[j][k]=="A+"
                append!(temp,19)
            elseif sector_data[j][k]=="A"
                append!(temp,18)
            elseif sector_data[j][k]=="A-"
                append!(temp,17)
            elseif sector_data[j][k]=="BBB+"
                append!(temp,16)
            elseif sector_data[j][k]=="BBB"
                append!(temp,15)
            elseif sector_data[j][k]=="BBB-"
                append!(temp,14)
            elseif sector_data[j][k]=="BB+"
                append!(temp,13)
            elseif sector_data[j][k]=="BB"
                append!(temp,12)
            elseif sector_data[j][k]=="BB-"
                append!(temp,11)
            elseif sector_data[j][k]=="B+"
                append!(temp,10)
            elseif sector_data[j][k]=="B"
                append!(temp,9)
            elseif sector_data[j][k]=="B-"
                append!(temp,8)
            elseif sector_data[j][k]=="CCC+"
                append!(temp,7)
            elseif sector_data[j][k]=="CCC"
                append!(temp,6)
            elseif sector_data[j][k]=="CCC-"
                append!(temp,5)
            elseif sector_data[j][k]=="CC"
                append!(temp,4)
            elseif sector_data[j][k]=="C"
                append!(temp,3)
            elseif sector_data[j][k]=="SD"
                append!(temp,2)
            elseif sector_data[j][k]=="D"
                append!(temp,2)
            elseif sector_data[j][k]=="N.M."
                append!(temp, 0)
            else
                append!(temp, 0)
            end

        end

        data=hcat(data,temp,makeunique = true)
    end
    sector_data = sector_dict[sector]
    gvkey=unique(sector_data[:1])
    names!(data,Symbol.(gvkey))
    key_new = sector*"_num"
    numerical_data_dict[key_new] = data
end

head(numerical_data_dict["sector_60_num"])

notch_dict = Dict()
for key in ["sector_10_num","sector_15_num","sector_20_num","sector_25_num","sector_30_num","sector_35_num","sector_40_num","sector_45_num","sector_50_num","sector_55_num","sector_60_num"]
    data = numerical_data_dict[key]
    sing_mult_notch=DataFrame(single=[],multi=[])
    sing_percentage=[]
    mult_percentage=[]
    for j in 1:size(data)[2]
        notch=[0,0]
        for k in 1:size(data)[1]-1
            if abs(data[k,j]-data[k+1,j])==1
                if data[k,j]!=-2 # missing = -2
                    notch[1] = notch[1]+1
                end
            elseif abs(data[k,j]-data[k+1,j])>1
                if data[k,j]!=-2 # missing = -2
                    notch[2] =notch[2]+1
                end            
            end
        end
        push!(sing_mult_notch,notch)
        append!(sing_percentage,notch[1]/sum(notch))
        append!(mult_percentage,notch[2]/sum(notch))
    end
    sing_mult_notch=hcat(sing_mult_notch,sing_percentage)
    sing_mult_notch=hcat(sing_mult_notch,mult_percentage,makeunique=true)
    rename!(sing_mult_notch,:x1,:single_percentage)
    rename!(sing_mult_notch,:x1_1,:multi_percentage)
    notch_dict[key] = sing_mult_notch
    print(key,"\n")
    println("single notch percentage: ",sum(sing_mult_notch[1])/(sum(sing_mult_notch[1])+sum(sing_mult_notch[2])))
    println("multi  notch percentage: ",1-sum(sing_mult_notch[1])/(sum(sing_mult_notch[1])+sum(sing_mult_notch[2])))
end

notch_dict["sector_60_num"]

tran_mat_dict = Dict()
tran_prob_dict = Dict()
for key in ["sector_10_num","sector_15_num","sector_20_num","sector_25_num","sector_30_num","sector_35_num","sector_40_num","sector_45_num","sector_50_num","sector_55_num","sector_60_num"]
    data = numerical_data_dict[key]
    trans=zeros(23,23)
    trans2 = zeros(23,23)
    for j in 1:size(data)[2]
        for k in 1:size(data)[1]-1
            if data[k,j]>0 && data[k+1,j]>0
                trans[data[k,j],data[k+1,j]]=trans[data[k,j],data[k+1,j]]+1
            end
        end
    end
    transframe=DataFrame(trans)
    tran_mat_dict[key] = transframe
    for l in 1:22
        trans2[l,:]=trans[l,:]/sum(trans[l,:])
    end
    transframe2=DataFrame(trans2)
    tran_prob_dict[key] = transframe2
end

replace_nan(v) = map(x -> isnan(x) ? zero(x) : x, v)

tran_prob_dict["sector_60_num"] = map(replace_nan, eachcol(tran_prob_dict["sector_60_num"]))

head(tran_mat_dict["sector_60_num"])

head(tran_prob_dict["sector_60_num"])


