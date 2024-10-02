/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241002@Mira
Task : Recover file upload data
DB: bodb_OWP	

Revisions:
	20241002@Mira: Recover file upload name [Redmine: #211716]
*/

SET IDENTITY_INSERT FileUpload ON;
INSERT INTO FileUpload (FileId, Title, CreatedDate, SavedFileName) VALUES
(20762, 'Jacky.png', '2024-10-01 00:00:00', '20762_Jacky.png'),
(20640, 'cappy.webp', '2024-10-01 00:00:00', '20640_cappy.webp'),
(21147, '2024-08-04_16-34-23.png', '2024-10-01 00:00:00', '21147_2024-08-04_16-34-23.png'),
(21253, 'Zimomo.jpeg', '2024-10-01 00:00:00', '21253_Zimomo.jpeg'),
(20695, '03.jpg', '2024-10-01 00:00:00', '20695_03.jpg'),
(21203, '7.jpg', '2024-10-01 00:00:00', '21203_7.jpg'),
(21805, 'name.png', '2024-10-01 00:00:00', '21805_name.png'),
(21079, 'LOUIS Chromelablab.png', '2024-10-01 00:00:00', '21079_LOUIS Chromelablab.png'),
(21176, 'OCPhoto.744609079.346006.jpeg', '2024-10-01 00:00:00', '21176_OCPhoto.744609079.346006.jpeg'),
(21256, 'images.png', '2024-10-01 00:00:00', '21256_images.png'),
(20535, 'Screenshot 2023-07-26 140729.png', '2024-10-01 00:00:00', '20535_Screenshot 2023-07-26 140729.png'),
(20623, 'add.jpeg', '2024-10-01 00:00:00', '20623_add.jpeg'),
(21673, 'YS.PNG', '2024-10-01 00:00:00', '21673_YS.PNG'),
(20546, 'Screenshot 2024-07-25 162651.png', '2024-10-01 00:00:00', '20546_Screenshot 2024-07-25 162651.png'),
(20600, 'pngtree-yellow-round-puffer-fish-illustration-image_1406218.jpg', '2024-10-01 00:00:00', '20600_pngtree-yellow-round-puffer-fish-illustration-image_1406218.jpg'),
(20524, 'photo_2020-08-07_09-49-18.jpg', '2024-10-01 00:00:00', '20524_photo_2020-08-07_09-49-18.jpg'),
(20602, 'pngtree-cartoon-clipart-dark-blue-stingray-png-image_2933855.jpg', '2024-10-01 00:00:00', '20602_pngtree-cartoon-clipart-dark-blue-stingray-png-image_2933855.jpg'),
(20637, 'hinh-anh-con-sau-xanh-beo-de-thuong-png-615.jpg', '2024-10-01 00:00:00', '20637_hinh-anh-con-sau-xanh-beo-de-thuong-png-615.jpg'),
(21084, 'ppata.png', '2024-10-01 00:00:00', '21084_ppata.png'),
(20536, '5800_5_03.jpg', '2024-10-01 00:00:00', '20536_5800_5_03.jpg'),
(21635, 'cropped-150-150-1354305.jpeg', '2024-10-01 00:00:00', '21635_cropped-150-150-1354305.jpeg'),
(20932, 'Screenshot 2024-07-31 170323.png', '2024-10-01 00:00:00', '20932_Screenshot 2024-07-31 170323.png'),
(20668, '6DFD760C-A6F0-49DE-96BA-5F13CAEC8108111.jpg', '2024-10-01 00:00:00', '20668_6DFD760C-A6F0-49DE-96BA-5F13CAEC8108111.jpg'),
(21323, 'Munn.jpg', '2024-10-01 00:00:00', '21323_Munn.jpg'),
(21013, 'hinh-nen-ton-ngo-khong-1080p_043205444.jpg', '2024-10-01 00:00:00', '21013_hinh-nen-ton-ngo-khong-1080p_043205444.jpg'),
(20636, 'Edik.png', '2024-10-01 00:00:00', '20636_Edik.png'),
(21650, 'Screenshot 2024-08-18 191234.png', '2024-10-01 00:00:00', '21650_Screenshot 2024-08-18 191234.png'),
(20532, 'orplt26x3un01.webp', '2024-10-01 00:00:00', '20532_orplt26x3un01.webp'),
(20573, 'image.gif', '2024-10-01 00:00:00', '20573_image.gif'),
(20531, 'image_2024-04-22_17-27-03.png', '2024-10-01 00:00:00', '20531_image_2024-04-22_17-27-03.png'),
(21025, 'image_2024_08_02T05_48_21_641Zaa.png', '2024-10-01 00:00:00', '21025_image_2024_08_02T05_48_21_641Zaa.png'),
(21232, 'Inside-Out-2-envy.jpg', '2024-10-01 00:00:00', '21232_Inside-Out-2-envy.jpg'),
(21023, 'ImportedPhoto.740932846.758746 (1).jpeg', '2024-10-01 00:00:00', '21023_ImportedPhoto.740932846.758746 (1).jpeg'),
(21802, 'maxresdefault.jpg', '2024-10-01 00:00:00', '21802_maxresdefault.jpg'),
(20656, 'cherry.jpg', '2024-10-01 00:00:00', '20656_cherry.jpg'),
(21851, 'images.png', '2024-10-01 00:00:00', '21851_images.png'),
(20624, 'Screenshot 2024-07-26 193637.png', '2024-10-01 00:00:00', '20624_Screenshot 2024-07-26 193637.png'),
(20628, 'image_2024_07_16T19_22_51_527Z.png', '2024-10-01 00:00:00', '20628_image_2024_07_16T19_22_51_527Z.png'),
(20553, 'image_2024_07_25T14_45_24_871Z.png', '2024-10-01 00:00:00', '20553_image_2024_07_25T14_45_24_871Z.png'),
(20533, 'avatar.jpg', '2024-10-01 00:00:00', '20533_avatar.jpg'),
(20537, '2.png', '2024-10-01 00:00:00', '20537_2.png');
SET IDENTITY_INSERT FileUpload OFF;