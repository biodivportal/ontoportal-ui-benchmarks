
bundle check
echo "StagePortal"
bundle exec ruby main.rb -u https://data.stageportal.lirmm.fr -k 1de0a270-29c5-4dda-b043-7c3580628cd5 --output-name stageportal
echo "AgroPortal"
bundle exec ruby main.rb -u https://data.agroportal.lirmm.fr -k 1de0a270-29c5-4dda-b043-7c3580628cd5 --output-name agroportal
echo "BioPortal LIRMM"
bundle exec ruby main.rb -u https://data.bioportal.lirmm.fr -k 1de0a270-29c5-4dda-b043-7c3580628cd5 --output-name bioportal-lirmm
echo "BioPortal Stanford"
bundle exec ruby main.rb -u https://data.bioontology.org -k  8b5b7825-538d-40e0-9e9e-5ab9274a9aeb --output-name bioportal-stanford
echo "EcoPortal"
bundle exec ruby main.rb -u https://data.ecoportal.lifewatch.eu -k 43a437ba-a437-4bf0-affd-ab520e584719 --output-name ecoportal
echo "EarthPortal"
bundle exec ruby main.rb -u  https://data.earthportal.eu  -k c9147279-954f-41bd-b068-da9b0c441288 --output-name earthportal
echo "BiodivPortal"
bundle exec ruby main.rb -u https://data.biodivportal.gfbio.org  -k 580f5b2f-64d0-4b1a-9c1a-41562297a654 --output-name biodivportal
echo "LovPortal"
bundle exec ruby main.rb -u https://data.lovportal.lirmm.fr  -k  13b97ee8-cdfb-4147-9260-af66e84b4afa --output-name lovportal

