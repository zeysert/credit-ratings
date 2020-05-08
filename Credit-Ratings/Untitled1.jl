
using DataFrames
using Dates

#read data
raw=readtable("raw.csv")

#drop the ones that does not have ratings
raw2=dropmissing(raw)

raw2[raw2[:6].=="AIR",:][:2];

#take out the ticker
ticker=unique(raw2[:6])

#Joining all companies into one dataframe, will take a while, please be patient
all=DataFrame(datadate=0)
for itr in enumerate(ticker)
#     println(itr[2])
    temp1=raw2[raw2[:6].==itr[2],:][2:3]
    all=join(all,temp1,on= :datadate, kind= :outer)
end


real_all=all[2:end,:]
sort!(real_all);

data=DataFrame()
for j in 2:size(real_all)[2]
    temp=[]
    for k in 1:size(real_all)[1]
        if ismissing(real_all[j][k])
            append!(temp,0)
        elseif real_all[j][k]=="AAA"
            append!(temp,22)
        elseif real_all[j][k]=="AA+"
            append!(temp,21)
        elseif real_all[j][k]=="AA"
            append!(temp,20)
        elseif real_all[j][k]=="AA-"
            append!(temp,19)
        elseif real_all[j][k]=="A+"
            append!(temp,18)
        elseif real_all[j][k]=="A"
            append!(temp,17)
        elseif real_all[j][k]=="A-"
            append!(temp,16)
        elseif real_all[j][k]=="BBB+"
            append!(temp,15)
        elseif real_all[j][k]=="BBB"
            append!(temp,14)
        elseif real_all[j][k]=="BBB-"
            append!(temp,13)
        elseif real_all[j][k]=="BB+"
            append!(temp,12)
        elseif real_all[j][k]=="BB"
            append!(temp,11)
        elseif real_all[j][k]=="BB-"
            append!(temp,10)
        elseif real_all[j][k]=="B+"
            append!(temp,9)
        elseif real_all[j][k]=="B"
            append!(temp,8)
        elseif real_all[j][k]=="B-"
            append!(temp,7)
        elseif real_all[j][k]=="CCC+"
            append!(temp,6)
        elseif real_all[j][k]=="CCC"
            append!(temp,5)
        elseif real_all[j][k]=="CCC-"
            append!(temp,4)
        elseif real_all[j][k]=="CC"
            append!(temp,3)
        elseif real_all[j][k]=="C"
            append!(temp,2)
        elseif real_all[j][k]=="SD"
            append!(temp,1)
        else
            append!(temp,0)
        end
        
    end
    
    data=hcat(data,temp)
end

#test
data=DataFrame()
for j in 2:size(real_all)[2]
    temp=[]
    for k in 1:size(real_all)[1]
        if ismissing(real_all[j][k])
            append!(temp,-2)
        elseif real_all[j][k]=="AAA"
            append!(temp,23)
        elseif real_all[j][k]=="AA+"
            append!(temp,22)
        elseif real_all[j][k]=="AA"
            append!(temp,21)
        elseif real_all[j][k]=="AA-"
            append!(temp,20)
        elseif real_all[j][k]=="A+"
            append!(temp,19)
        elseif real_all[j][k]=="A"
            append!(temp,18)
        elseif real_all[j][k]=="A-"
            append!(temp,17)
        elseif real_all[j][k]=="BBB+"
            append!(temp,16)
        elseif real_all[j][k]=="BBB"
            append!(temp,15)
        elseif real_all[j][k]=="BBB-"
            append!(temp,14)
        elseif real_all[j][k]=="BB+"
            append!(temp,13)
        elseif real_all[j][k]=="BB"
            append!(temp,12)
        elseif real_all[j][k]=="BB-"
            append!(temp,11)
        elseif real_all[j][k]=="B+"
            append!(temp,10)
        elseif real_all[j][k]=="B"
            append!(temp,9)
        elseif real_all[j][k]=="B-"
            append!(temp,8)
        elseif real_all[j][k]=="CCC+"
            append!(temp,7)
        elseif real_all[j][k]=="CCC"
            append!(temp,6)
        elseif real_all[j][k]=="CCC-"
            append!(temp,5)
        elseif real_all[j][k]=="CC"
            append!(temp,4)
        elseif real_all[j][k]=="C"
            append!(temp,3)
        elseif real_all[j][k]=="SD"
            append!(temp,2)
        elseif real_all[j][k]=="D"
            append!(temp,1)
        elseif real_all[j][k]=="N.M."
            append!(temp,0)    
        else
            append!(temp,0)
        end
    end
    data=hcat(data,temp)
end

ref_list=Dict("AAA"=>23,"AA+"=>22,"AA"=>21,"AA-"=>20,"A+"=>19,"A"=>18,"A-"=>17,"BBB+"=>16,"BBB"=>15,
    "BBB-"=>14,"BB+"=>13,"BB"=>12,"BB-"=>11,"B+"=>10,"B"=>9,"B-"=>8,"CCC+"=>7,"CCC"=>6,"CCC-"=>5,"CC"=>4,"C"=>3,"SD"=>2,"D"=>1,
    "NM"=>0,"missing"=>-2)
sort(ref_list);

timeframe=DataFrame(Date=[])
# Dates.DateTime(string(real_all[1,1]),"yyyymmdd")
# Dates.DateTime(string(real_all[1,:1]),"yyyymmdd")
# push!(timeframe,1)
for i in 1:size(real_all)[1]
    timeframe=vcat(timeframe,Dates.DateTime(string(real_all[i,1]),"yyyymmdd"))
end
timeframe=timeframe[2:end];

size(data)

using Plots

#may also take awhile
plot()
start=1
en_d=3
plot!([data[i] for i in start:en_d],label=[ticker[k] for k in start:en_d])


#plot using tick
wantick=["AIR","4165A","AMESQ"]
ranges=[]
for i in wantick
    append!(ranges,findall(ticker.==i))
end

plot()
plot!(timeframe,[data[i] for i in ranges],label=[ticker[k] for k in ranges])


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
rename!(sing_mult_notch,:x1,:single_percentage)
rename!(sing_mult_notch,:x1_1,:multi_percentage)
println("single notch percentage: ",sum(sing_mult_notch[1])/(sum(sing_mult_notch[1])+sum(sing_mult_notch[2])))
println("multi  notch percentage: ",1-sum(sing_mult_notch[1])/(sum(sing_mult_notch[1])+sum(sing_mult_notch[2])))

head(sing_mult_notch)

println("single: ",sum(sing_mult_notch[1]),"\nmulti : ",sum(sing_mult_notch[2]))

trans=zeros(23,23)
for j in 1:size(data)[2]
    for k in 1:size(data)[1]-1
        if data[k,j]>0 && data[k+1,j]>0
            trans[data[k,j],data[k+1,j]]=trans[data[k,j],data[k+1,j]]+1
        end
    end
end
transframe=DataFrame(trans)

trans2=zeros(23,23)
for j in 1:23
    trans2[j,:]=trans[j,:]/sum(trans[j,:])
end
DataFrame(trans2)


sort(ref_list)


#group up A B C D SD
basket=zeros(5,5)
for j in enumerate([1,2,3:7,8:16,17:23])
    for k in enumerate([1,2,3:7,8:16,17:23])
        basket[j[1],k[1]]=sum(trans[j[2],k[2]])
    end
    basket[j[1],:]=basket[j[1],:]/sum(basket[j[1],:])
end

basket #SD D C B A

unique(raw2[:4])


