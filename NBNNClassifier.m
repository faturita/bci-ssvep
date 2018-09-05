function [ACC, ERR, AUC, SC] = NBNNClassifier(F,DE,channel,testRange,labelRange,graphics)

comps = 0;

SC = {};
SC.CLSF = {};

%figure;
fprintf('Classifying features %d\n', size(DE.CLSTER,2));

% First check if I have at least two differente classes.
if (size(DE.CLSTER,2)<2)
    fprintf('Less than two classifying clusters. \n');
    ACC=0;
elseif (size(DE.C,2)<2)
    fprintf('Just one cluster, no classification \n');
    ACC=0;
else
    %for channel=channelRange
    fprintf ('Channel %d -------------\n', channel);

    %M = MM(channel).M;
    %IX = MM(channel).IX;

    predicted = [];

    expected = labelRange(testRange);
    

    % For each signal window, grab the descriptors and check where they are
    for test=testRange
        DESCRIPTORS =  F(channel, labelRange(test), test).descriptors;

        if (comps>0)
            DESCRIPTORS  =  ((DESCRIPTORS)' * coeff)';
            DESCRIPTORS=DESCRIPTORS(1:comps,:);
        end

        if (size(DESCRIPTORS,2) == 0)
            DESCRIPTORS
            channel
            labelRange(test)
            test
            error('No Descriptor were found for this query image.  Labels could have been altered in a wrong way.');
        end

        % Voy a calcular esto: C_hat = arg min SUM || d_i - kNN_c (d_i) ||
        SUMSUM = [];
        for clster=1:size(DE.C,2)
            SUM = 0;

            % IDX contains all the ids of the near descriptors of each one
            % of the descriptors of the current query image.
            [IDX, D] = vl_kdtreequery(DE.C(clster).KDTree,DE.C(clster).M,DESCRIPTORS,'NumNeighbors',7);
            
            SUM = sum(sum(D));
            
            SC.CLSF{test}.IDX{clster} = IDX;   
            
            SUMSUM = [SUMSUM SUM];
        end
        % I am assumming that the order matches the labels.
        [C, I] = min(SUMSUM);
        predicted = [predicted DE.C(I(1)).Label];

        SC.CLSF{test}.predicted = DE.C(I(1)).Label;    
        
        if (graphics)
            for i=1:size(DESCRIPTORS',1)
                KL=DESCRIPTORS';
                if (DE.C(I(1)).Label == 1)
                    line(KL(i,1),KL(i,2),'marker','X','color','b',...
                        'markersize',10,'linewidth',2,'linestyle','none');
                elseif (DE.C(I(1)).Label == 2)
                    line(KL(i,1),KL(i,2),'marker','X','color','r',...
                        'markersize',10,'linewidth',2,'linestyle','none');
                end
            end
        end

    end
    
    %predicted=randi(unique(labelRange),size(expected))

    C=confusionmat(expected, predicted)

    %if (C(1,1)+C(2,2) > 65)
    %    error('done');
    %end

    %[X,Y,T,AUC] = perfcurve(expected,single(predicted==2),2);
    [X,Y,T,AUC] = perfcurve(expected,predicted,2);

    %figure;plot(X,Y)
    %xlabel('False positive rate')
    %ylabel('True positive rate')
    %title('ROC for Classification of P300')


    if (size(C,1)==2)
        ACC = (C(1,1)+C(2,2)) / size(predicted,2);
        ERR = size(predicted,2) - (C(1,1)+C(2,2));

        SC.FP = C(2,1);
        SC.TP = C(2,2);
        SC.FN = C(1,2);
        SC.TN = C(1,1);
        
        [ACC, (SC.TP/(SC.TP+SC.FP))]

        SC.expected = expected;
        SC.predicted = predicted;    
    else
        SC.expected = expected;
        SC.predicted = predicted; 

        ACC = (C(1,1)+C(2,2)+C(3,3)) / size(predicted,2);
        ERR = size(predicted,2) - (C(1,1)+C(2,2)+C(3,3));
        
        SC.C = C;
        
        %error('IT MUST BE ONE OR THE OTHER.  Confusion matrix is not 2-2.');
        %ACC = (   C(2,2)+C(3,3)  )  / size(predicted,2)  ;
        %ERR = size(predicted,2) - (C(2,2)+C(3,3));
    end

end

if (graphics)
    title(sprintf('Exp.%d:Clusters  BCI-SIFT PCA %d Comp', expcode,comps));
    xlabel('X')
    ylabel('Y')
end

end
