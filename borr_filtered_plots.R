library(plotly)
borr <- read.table("~/Sites/d3lab/borrFilter/data/borrFilter-usor.tsv3", sep="\t", header=T, stringsAsFactors = FALSE)

borr <- borr[order(borr$lyme, borr$rf),]

p <- plot_ly(borr, x = ~locus, y = ~lyme, type='bar', name='Lyme',hoverinfo='text',text= ~paste('locus: ', locus, '\ncopy: ', lyme, '\nanno: ', anno), marker=list(color='#d4b2b2')) %>% 
            add_trace(y = ~rf, name = 'Relapsing Fever', hoverinfo='text', text=~paste('locus: ', locus, '\ncopy: ', rf, '\nanno: ', anno), marker=list(color='#8fa382')) %>% 
            layout(title='Differences between 2 groups: Relapsing fever and Lyme disease', xaxis=list(showticklabels=FALSE, categoryorder='array', categoryarray=borr$locus), yaxis=list(title="copies"), legend = list(x=0, y=1))


#g1 <- ggplot(x, aes(factor(x$locus), x$value, fill = x$variable)) + geom_bar(stat = "identity", position = "dodge") + theme(axis.text.x = element_text(angle = 90, hjust = 1))
