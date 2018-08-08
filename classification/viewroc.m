function auc = viewroc(classes, scores, publish)
% Creates ROC curve
%
% classes are the true classes (vector)
% scores are the classification outputs (vector)
% publish is optional (1 means publish)
%
% auc is the area under the curve

pclass = max(classes);
[X,Y,~,auc,OPTROCPT] = perfcurve(classes,scores,pclass);
hold on
plot(X,Y,'k','linewidth',3);
text(0.4,0.2,['AUC = ',num2str(auc,2)]);
ylabel('Sensitivity');
xlabel('1 - Specificity');
set(gca, 'box', 'off');
set(gcf,'color','white');

if exist('publish','var') && publish
    set(gca,'fontsize',16);
end
